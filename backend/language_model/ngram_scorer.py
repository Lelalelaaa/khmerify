import json
from pathlib import Path


MODEL_PATH = Path(__file__).resolve().parent / "bigram_model.json"


def score_candidate(previous_word: str, candidate_word: str) -> int:
	with MODEL_PATH.open("r", encoding="utf-8") as model_file:
		bigram_model = json.load(model_file)

	return bigram_model.get(previous_word, {}).get(candidate_word, 0)
