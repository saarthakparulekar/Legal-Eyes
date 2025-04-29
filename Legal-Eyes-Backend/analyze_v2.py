import os
import json
import numpy as np
from sentence_transformers import SentenceTransformer
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
from nltk.corpus import stopwords
from nltk.tokenize import word_tokenize
from nltk.corpus import wordnet as wn
import re

# Setup paths
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
IPC_FILE_PATH = os.path.join(BASE_DIR, 'ipc_sections.json')

# Load IPC data
with open(IPC_FILE_PATH, 'r', encoding='utf-8') as file:
    ipc_sections = json.load(file)

# Combine section text for analysis
section_ids = [sec['Section'] for sec in ipc_sections]
section_texts = [
    (sec['section_title'] + " " + sec['section_desc']).lower()
    for sec in ipc_sections
]

# Load Sentence-BERT model
bert_model = SentenceTransformer('all-MiniLM-L6-v2')

# Load stopwords and add legal-specific stopwords
stop_words = set(stopwords.words('english'))
legal_stopwords = {'section', 'act', 'ipc', 'indian', 'penal', 'code', 'chapter', 'part'}
stop_words.update(legal_stopwords)

# Function to clean and normalize text
def clean_and_normalize(text):
    # Remove special characters and numbers
    text = re.sub(r'[^a-zA-Z\s]', ' ', text)
    # Convert to lowercase
    text = text.lower()
    # Remove extra whitespace
    text = ' '.join(text.split())
    return text

# Function to extract meaningful words
def clean_and_tokenize(text):
    text = clean_and_normalize(text)
    words = word_tokenize(text)
    # Handle compound words related to vehicles
    words.extend([
        word.replace('-', '') for word in words 
        if '-' in word and any(veh in word.lower() for veh in ['car', 'vehicle', 'auto', 'bike'])
    ])
    # Keep only meaningful words (no stopwords, numbers, or single characters)
    return [word for word in words if word not in stop_words and len(word) > 1]

# Get synonyms for each word with legal context
def get_synonyms(word):
    synonyms = set()
    # Only get synonyms for words that might have legal significance
    if len(word) > 3:  # Avoid short words that might be too generic
        for syn in wn.synsets(word):
            # Filter by domain - prefer legal and formal contexts
            if any(tag in syn.lexname() for tag in ['noun.act', 'noun.communication', 'noun.cognition']):
                for lemma in syn.lemmas():
                    synonym = lemma.name().replace('_', ' ')
                    if len(synonym) > 3:  # Avoid short synonyms
                        synonyms.add(synonym)
    return list(synonyms)

def get_crime_severity_weight(text, section_text, section_id):
    # Add weight for violent crimes when death/murder is mentioned
    death_keywords = {
        'kill', 'death', 'murder', 'homicide', 'fatal', 'dead', 'killed',
        'slay', 'slain', 'assassinate', 'execute', 'terminate', 'eliminate',
        'manslaughter', 'fatal accident', 'fatal crash', 'fatal collision',
        'ran over', 'run over', 'knocked down', 'vehicular manslaughter',
        'deceased', 'died', 'loss of life', 'killed people', 'killed person',
        'caused death', 'death of', 'lost life', 'lost their life'
    }
    
    # Add multi-word phrases for better matching
    death_phrases = {
        'killed two people', 'killed multiple people', 'caused death of',
        'resulted in death', 'led to death', 'death of people',
        'killed several people', 'multiple casualties'
    }
    
    vehicle_keywords = {
        'car', 'vehicle', 'automobile', 'bike', 'motorcycle', 'truck', 'van', 
        'suv', 'auto', 'driving', 'driver', 'drove', 'drive', 'transport',
        'rash', 'negligent', 'accident', 'collision', 'crash', 'hit', 'run',
        'traffic', 'speeding', 'drunk', 'dui', 'dwi', 'ran over', 'run over',
        'knocked down', 'struck', 'rammed', 'collided', 'smashed', 'vehicular',
        'crashed', 'crashing', 'impacted', 'hit and run', 'fatal crash'
    }
    
    # Add multi-word vehicle phrases
    vehicle_phrases = {
        'crashed into', 'collided with', 'hit and run', 'ran into',
        'struck by vehicle', 'vehicle collision', 'car accident',
        'traffic accident', 'road accident', 'vehicle crash'
    }
    
    text_lower = text.lower()
    text_tokens = set(clean_and_tokenize(text_lower))
    
    # Check for death keywords and phrases
    has_death_keywords = (
        any(keyword in text_tokens for keyword in death_keywords) or
        any(phrase in text_lower for phrase in death_phrases) or
        any(phrase in text_lower for phrase in death_keywords)
    )
    
    # Check for vehicle keywords and phrases
    has_vehicle_keywords = (
        any(keyword in text_tokens for keyword in vehicle_keywords) or
        any(phrase in text_lower for phrase in vehicle_phrases) or
        any(phrase in text_lower for phrase in vehicle_keywords)
    )
    
    # Check for drunk driving specifically
    drunk_keywords = {'drunk', 'intoxicated', 'alcohol', 'dui', 'dwi', 'under influence'}
    has_drunk_driving = (
        any(word in text_tokens for word in drunk_keywords) and
        has_vehicle_keywords
    )
    
    # Extract the numeric part of the section ID
    section_number = ''.join(filter(str.isdigit, str(section_id)))
    
    # Calculate weights based on crime combinations
    weight = 1.0
    
    # Base weight adjustment for death-related sections
    if has_death_keywords:
        if section_number == '304A':
            weight *= 2.0
        elif section_number in {'299', '300', '301', '302', '304'}:
            weight *= 1.5
    
    # Highest priority for death by negligence in vehicle cases
    if section_number == '304A':
        if has_vehicle_keywords and has_death_keywords:
            weight *= 6.0  # Further increased for vehicle-related deaths
            if has_drunk_driving:
                weight *= 2.0
        elif has_vehicle_keywords:
            weight *= 4.0  # Increased base weight for vehicle cases
        elif has_death_keywords:
            weight *= 3.0
    
    # Secondary priority for rash driving
    elif section_number == '279' and has_vehicle_keywords:
        weight *= 2.2
        if has_death_keywords:
            weight *= 1.5
        if has_drunk_driving:
            weight *= 1.8
            
    # Special handling for drunk driving cases
    elif section_number in {'85', '86'} and has_drunk_driving:
        weight *= 2.8
        if has_vehicle_keywords:
            weight *= 1.8
        if has_death_keywords:
            weight *= 2.0
            
    # Other weights for related sections
    elif section_number in {'299', '300', '301', '302', '304'}:
        if has_death_keywords:
            weight *= 1.8
            if has_vehicle_keywords:
                weight *= 1.2  # Reduced to prevent overshadowing 304A
    elif has_vehicle_keywords and section_number in {'337', '338'}:
        weight *= 1.8  # Reduced to prevent overshadowing 304A
        if has_death_keywords:
            weight *= 1.3
            
    return weight

# Main function
def findSection(description):
    tokens = clean_and_tokenize(description)
    
    # Add synonyms to the token list
    expanded_tokens = tokens.copy()
    for word in tokens:
        expanded_tokens.extend(get_synonyms(word))
        # Add vehicle-specific synonyms
        if word in {'car', 'vehicle', 'auto'}:
            expanded_tokens.extend(['automobile', 'motor', 'transport', 'vehicular'])
        elif word in {'hit', 'struck', 'ram', 'ran', 'run'}:  # Added 'ran' and 'run'
            expanded_tokens.extend(['collide', 'crash', 'smash', 'impact', 'accident'])
        elif word in {'kill', 'death', 'dead'}:  # Added 'dead'
            expanded_tokens.extend(['manslaughter', 'fatal', 'lethal', 'deceased'])
        elif word in {'drunk', 'intoxicated', 'dui', 'dwi'}:  # Added 'dui' and 'dwi' here
            expanded_tokens.extend(['alcohol', 'impaired', 'under influence', 'inebriated'])

    expanded_description = " ".join(set(expanded_tokens))

    # BERT-based similarity
    input_embedding = bert_model.encode([expanded_description])[0]
    section_embeddings = bert_model.encode(section_texts)

    matched_sections = []
    for sec_id, sec_data, sec_emb in zip(section_ids, ipc_sections, section_embeddings):
        # Skip sections with empty descriptions
        if not sec_data.get('section_desc', '').strip():
            continue
            
        similarity = cosine_similarity([input_embedding], [sec_emb])[0][0]
        
        # Apply weight based on crime severity
        weight = get_crime_severity_weight(description, sec_data['section_desc'], sec_data['Section'])
        adjusted_similarity = similarity * weight
        
        if adjusted_similarity > 0.25:  # Lowered threshold for vehicle-related crimes
            matched_sections.append({
                "Section": str(sec_data['Section']),  # Convert section number to string
                "Title": sec_data['section_title'],
                "Description": sec_data['section_desc'],
                "Score": float(round(adjusted_similarity, 3))
            })

    matched_sections.sort(key=lambda x: x["Score"], reverse=True)

    if not matched_sections:
        return {"Verdict": "❌ No relevant IPC section found.", "Matches": []}

    best_match = matched_sections[0]
    other_matches = [match for match in matched_sections[1:7] if match["Score"] > 0.3]

    return {
        "Verdict": {
            "Section": best_match["Section"],
            "Title": best_match["Title"],
            "Description": best_match["Description"],
            "Score": best_match["Score"]
        },
        "Matches": other_matches
    }

# For standalone testing
if __name__ == "__main__":
    description = input("Enter the crime description: ")
    result = findSection(description)

    print("\n🚨 BEST MATCHED IPC SECTION 🚨")
    verdict = result["Verdict"]
    
    if isinstance(verdict, str):  # No matches found
        print(verdict)
    else:
        print(f"📌 Section: {verdict['Title']} (IPC {verdict['Section']})")
        print(f"🔍 Score: {verdict['Score']}")
        print(f"📖 {verdict['Description']}")

        if result["Matches"]:
            print("\n📚 OTHER POSSIBLE MATCHES:")
            for match in result["Matches"]:
                print(f"- {match['Title']} (IPC {match['Section']}) → Score: {match['Score']}")
