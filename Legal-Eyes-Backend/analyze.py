def findSection(description):
    if 'steal' in description or 'theft' in description or 'rob' in description or 'stole' in description:
        return 'Section 378 : Theft'
    elif 'kill' in description or 'murder' in description:
        return 'Section 302 : Murder'
    else:
        return 'Sorry, could not find relevant section'