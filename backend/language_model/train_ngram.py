import json
from collections import defaultdict
from pathlib import Path


BASE_DIR = Path(__file__).resolve().parent
CORPUS_PATH = BASE_DIR / "corpus.txt"
MODEL_PATH = BASE_DIR / "bigram_model.json"
WORDS_PATH = BASE_DIR.parent / "data" / "words.json"


def load_khmer_words() -> list[str]:
	with WORDS_PATH.open("r", encoding="utf-8") as words_file:
		words = json.load(words_file)

	vocabulary = {
		value
		for key, value in words.items()
		if key != "_ambiguous" and " " not in key
	}
	return sorted(vocabulary, key=len, reverse=True)


def tokenize_line(line: str, vocabulary: list[str]) -> list[str]:
	text = line.strip()
	tokens = []
	i = 0

	while i < len(text):
		if text[i].isspace():
			i += 1
			continue

		match = next((word for word in vocabulary if text.startswith(word, i)), None)
		if match:
			tokens.append(match)
			i += len(match)
			continue

		if text[i] in "។,!?៖;:()":
			if tokens:
				tokens[-1] += text[i]
			i += 1
			continue

		i += 1

	return tokens


def train() -> dict[str, dict[str, int]]:
	bigram_counts = defaultdict(lambda: defaultdict(int))
	vocabulary = load_khmer_words()

	with CORPUS_PATH.open("r", encoding="utf-8") as corpus_file:
		for line in corpus_file:
			words = tokenize_line(line, vocabulary)
			for previous_word, candidate_word in zip(words, words[1:]):
				bigram_counts[previous_word][candidate_word] += 1

	return {previous: dict(candidates) for previous, candidates in bigram_counts.items()}


if __name__ == "__main__":
	model = train()
	with MODEL_PATH.open("w", encoding="utf-8") as model_file:
		json.dump(model, model_file, ensure_ascii=False, indent=2)
