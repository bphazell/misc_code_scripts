
import argparse, fileinput, json, ast, subprocess, os
from pprint import pprint
import pandas as pd
import collections
from collections import OrderedDict
# from spot_check_results_utils import *
from apple_test_utils import *
import random
from fuzzywuzzy import fuzz
from fuzzywuzzy import process

os.chdir("Desktop/")

INPUT_FILE = "apple_source_a1239838.csv"

df = pd.read_csv(INPUT_FILE, encoding="utf-8")
df_not_goldent = df[~(df['_golden'])]
df_gold = df[df['_golden']]


# distance_stats = get_answer_distribution_by_distance

