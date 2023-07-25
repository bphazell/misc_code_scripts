import pandas as pd
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('-i', '--input', help="Name of input csv file.", type=str, required=True)
parser.add_argument('-o', '--output', help="Name of output csv file.", type=str)

parser.add_argument('-g', '--gold', help="Names of gold_answer columns separated by spaces.", nargs='+', type=str, required=True)
parser.add_argument('-a', '--answer', help="Names of answer columns separated by spaces.", nargs='+', type=str, required=True)
parser.add_argument('-c', '--correct', help="Names of correct columns separated by spaces.", nargs='+', type=str, required=True)
parser.add_argument('-f', '--confidence', help="Names of confidence columns separated by spaces.", nargs='+', type=str, required=True)
parser.add_argument('-t', '--taxonomy', help="Name of taxonomy_correct column.", type=str)
args = parser.parse_args()

fin = args.i__input
fout = args.o__output
gold_cols = args.g__gold
answ_cols = args.a__answer
corr_cols = args.c__correct
conf_cols = args.f__confidence

df = pd.read_csv(fin)
for i in df.index:
	if pd.isnull(df.at[i, gold_cols[0]]) and pd.isnull(df.at[i, answ_cols[0]]):
		for j in range(1, len(gold_cols)):
			if not pd.isnull(df.at[i, gold_cols[j]]) or not pd.isnull(df.at[i, answ_cols[j]]):
				df.at[i, gold_cols[0]] = df.at[i, gold_cols[j]]
				df.at[i, answ_cols[0]] = df.at[i, answ_cols[j]]
				df.at[i, conf_cols[0]] = df.at[i, conf_cols[j]]
				df.at[i, corr_cols[0]] = df.at[i, corr_cols[j]]
				break
print("\n")

if args.t__taxonomy:
	print("Taxonomy Average: %.3f" % df[args.t__taxonomy].mean())
print("Style Average: %.3f" % df[corr_cols[0]].mean())

if args.o__output:
	print("Saving new csv as %s" % fout)
print("\n")

df.to_csv(fout)