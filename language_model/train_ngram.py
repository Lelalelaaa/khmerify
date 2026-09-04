import json
from collections import defaultdict
from pathlib import Path


BASE_DIR = Path(__file__).resolve().parent
CORPUS_PATH = BASE_DIR / "corpus.txt"
MODEL_PATH = BASE_DIR / "bigram_model.json"


def train() -> dict[str, dict[str, int]]:
	bigram_counts = defaultdict(lambda: defaultdict(int))

	with CORPUS_PATH.open("r", encoding="utf-8") as corpus_file:
		for line in corpus_file:
			words = line.strip().split()
			for previous_word, candidate_word in zip(words, words[1:]):
				bigram_counts[previous_word][candidate_word] += 1

	return {previous: dict(candidates) for previous, candidates in bigram_counts.items()}


if __name__ == "__main__":
	model = train()
	with MODEL_PATH.open("w", encoding="utf-8") as model_file:
		json.dump(model, model_file, ensure_ascii=False, indent=2)
