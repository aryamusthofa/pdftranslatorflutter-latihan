import re

file_path = 'lib/translations.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Define the additions for ID and EN. For other languages, we'll append the EN version as fallback.
additions_id = "'limit_char_trans': 'Batas Karakter untuk Terjemahan:', 'limit_char_hint': 'Masukkan jumlah karakter (maks: ', 'limit_char_max': '⚠️ Maksimal ', 'limit_char_api': ' untuk stabilitas API', 'btn_reset': 'Reset', 'limit_detected': '📊 Terdeteksi: ', 'limit_chars': ' karakter', 'limit_will_translate': ' | Akan diterjemahkan: ', 'limit_pdf_has': 'PDF memiliki ', 'limit_above_api': ' karakter di atas limit aman API. Hanya ', 'limit_first_translated': ' karakter pertama yang akan diterjemahkan.', "

additions_en = "'limit_char_trans': 'Character Limit for Translation:', 'limit_char_hint': 'Enter character limit (max: ', 'limit_char_max': '⚠️ Maximum ', 'limit_char_api': ' for API stability', 'btn_reset': 'Reset', 'limit_detected': '📊 Detected: ', 'limit_chars': ' characters', 'limit_will_translate': ' | Will translate: ', 'limit_pdf_has': 'PDF has ', 'limit_above_api': ' characters above API safe limit. Only ', 'limit_first_translated': ' first characters will be translated.', "

def replacer(match):
    lang = match.group(1)
    if lang == 'id':
        return match.group(0).replace('},', additions_id + '},', 1)
    else:
        return match.group(0).replace('},', additions_en + '},', 1)

# Find each language block and inject the translations before the closing brace
new_content = re.sub(r"'(.*?)': \{.*?(?=\},^\s+')\},", replacer, content, flags=re.DOTALL | re.MULTILINE)

# Last block won't match the positive lookahead, so let's just do a simpler approach:
# Replace the last `    },` inside each language dictionary.
def replacer_simple(match):
    lang = match.group(1)
    body = match.group(2)
    injection = additions_id if lang == 'id' else additions_en
    return f"'{lang}': {{{body}{injection}"

new_content = re.sub(r"'([a-z]{2})': \{(.*?)(?=\s+\},)", replacer_simple, content, flags=re.DOTALL)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(new_content)
