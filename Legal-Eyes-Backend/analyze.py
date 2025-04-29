import json
import numpy as np
import os
import subprocess
import sys
from sentence_transformers import SentenceTransformer, losses, InputExample
from torch.utils.data import DataLoader
from sklearn.metrics.pairwise import cosine_similarity
import spacy
import nltk
from nltk.tokenize import word_tokenize
from nltk.corpus import stopwords

# Ensure necessary NLP resources are downloaded
nltk.download('punkt')
nltk.download('stopwords')

# Load pre-trained NLP model for Named Entity Recognition (NER)
try:
    nlp = spacy.load("en_core_web_sm")
except OSError:
    print("Downloading 'en_core_web_sm' model...")
    os.system("python -m spacy download en_core_web_sm")
    nlp = spacy.load("en_core_web_sm")

# Load or Fine-Tune the Model
def load_or_finetune_model():
    if os.path.exists("fine_tuned_legal_eyes"):
        print("✅ Loading existing fine-tuned model...")
        return SentenceTransformer("fine_tuned_legal_eyes")
    else:
        print("🔄 No trained model found. Fine-tuning now...")
        model = SentenceTransformer('all-MiniLM-L6-v2')
        return fine_tune_model(model)

# Fine-Tune the Model
def fine_tune_model(model):
    ipc_sections = load_ipc_sections()
    train_examples = [
        InputExample(texts=[sec['section_title'], sec['section_desc']])
        for sec in ipc_sections
    ]

    if not train_examples:
        raise ValueError("No valid training data found! Ensure JSON contains valid section descriptions.")

    train_dataloader = DataLoader(train_examples, shuffle=True, batch_size=16)
    train_loss = losses.ContrastiveLoss(model)

    print("🔄 Fine-tuning model with improved settings...")
    model.fit(train_objectives=[(train_dataloader, train_loss)], epochs=8, warmup_steps=100)
    
    model.save("fine_tuned_legal_eyes")
    print("✅ Fine-tuning complete with better performance!")
    return model

# Load IPC Sections (Exclude Definitions)
def load_ipc_sections():
    with open('ipc_sections.json', 'r', encoding='utf-8') as file:
        all_sections = json.load(file)

    filtered_sections = [
        sec for sec in all_sections
        if not any(keyword in sec["section_desc"].lower() for keyword in ["definition", "means", "includes"])
    ]

    print(f"✅ Loaded {len(filtered_sections)} IPC sections after filtering definitions.")
    return filtered_sections

# Preprocess Crime Description
def preprocess_text(text):
    stop_words = set(stopwords.words('english'))
    words = word_tokenize(text.lower())
    return " ".join([word for word in words if word.isalnum() and word not in stop_words])

# Match Crime to IPC Sections
def match_crime_to_ipc(crime_desc, model, ipc_sections):
    crime_desc = preprocess_text(crime_desc)
    crime_embedding = model.encode([crime_desc])

    ipc_texts = [f"{sec['section_title']} - {sec['section_desc']}" for sec in ipc_sections]
    ipc_embeddings = model.encode(ipc_texts)

    similarities = cosine_similarity(crime_embedding, ipc_embeddings)[0]
    sorted_matches = sorted(zip(ipc_sections, similarities), key=lambda x: x[1], reverse=True)
    
    best_match = sorted_matches[0][0]
    best_match_score = sorted_matches[0][1]
    
    all_possible_matches = [
        {"section": sec["section_title"], "section_number": sec["Section"], "description": sec["section_desc"], "similarity": sim}
        for sec, sim in sorted_matches if sim > 0.15
    ]

    return {
        "matched_section": best_match["section_title"],
        "section_number": best_match["Section"],
        "description": best_match["section_desc"],
        "similarity_score": best_match_score,
        "all_possible_matches": all_possible_matches
    }

# Main Execution
if __name__ == "__main__":
    model = load_or_finetune_model()
    ipc_sections = load_ipc_sections()

    crime_description = input("Enter crime description: ")
    result = match_crime_to_ipc(crime_description, model, ipc_sections)

    print("\n🚀 **Best Matched IPC Section** 🚀")
    print(f"📌 Section: {result['matched_section']} (IPC {result['section_number']})")
    print(f"🔍 Similarity Score: {result['similarity_score']:.2f}")
    print(f"📖 Description: {result['description']}")

    print("\n📌 **Possible Matches**:")
    for match in result['all_possible_matches']:
        print(f"- {match['section']} (IPC {match['section_number']}) - Similarity: {match['similarity']:.2f}")
        print(f"  Description: {match['description']}")
