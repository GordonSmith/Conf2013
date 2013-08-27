import Bundles.StringMatch;

LongestCommonSubstringRecord := record
  integer4 len;
  varstring str;
end;
TestRecord := record
  varstring Str1;
  varstring Str2;
  integer4 hammingDistance;
  integer4 levenshteinDistance;
  integer4 damerauLevenshteinDistance;
  integer4 optimalStringAlignmentDistance;
  real4 sift3BDistance;
  varstring longestCommonSubsequence;
  LongestCommonSubstringRecord longestCommonSubstring;
end;

SampleRecord := record
  varstring Str1;
  varstring Str2;
end;
TestDataset := dataset([
{'', ''},
{'', 'Grodox'},
{'Gordon', ''},
{'123456', '123'},
{'123', '123456'},
{'Gordon', 'Grodox'},
{'The lazy dog jumped over the fox', 'A lazy fox jumped over the dog'},
{'This Has', 'No_Common'}
], SampleRecord);

TestRecord TestStrAlgo(SampleRecord l) := transform
	self.hammingDistance := StringMatch.Distance.Hamming(l.Str1, l.Str2).Result;
	self.levenshteinDistance := StringMatch.Distance.Levenshtein(l.Str1, l.Str2).Result;
	self.damerauLevenshteinDistance := StringMatch.Distance.DamerauLevenshtein(l.Str1, l.Str2).Result;
	self.optimalStringAlignmentDistance := StringMatch.Distance.OptimalStringAlignment(l.Str1, l.Str2).Result;
	self.sift3BDistance := StringMatch.Distance.Sift3B(l.Str1, l.Str2).Result;
  	self.longestCommonSubsequence := StringMatch.LongestCommonSubsequence(l.Str1, l.Str2).Result;
  	lcs := StringMatch.LongestCommonSubstring(l.Str1, l.Str2);
  	self.longestCommonSubstring.len := lcs.MaxLen;
  	self.longestCommonSubstring.str := lcs.MaxStr;
	self := l;
end;

project(TestDataset, TestStrAlgo(left));
