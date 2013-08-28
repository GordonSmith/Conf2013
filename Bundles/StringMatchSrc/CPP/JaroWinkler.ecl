// Computes the Jaro distance between two string -- intrepreted from:
// http://en.wikipedia.org/wiki/Jaro%E2%80%93Winkler_distance
// s1 is the first string to compare
// s2 is the second string to compare
UNSIGNED INTEGER4 Winkler(STRING s1, STRING s2, REAL4 jaro, INTEGER4 prefixlength) := BEGINC++
#option pure
	#include <algorithm>
#body	
	if(lenS1 == 0 && lenS2 == 0) {
		return 0;
	} else if (lenS1 == 0) {
		return lenS2;
	} else if (lenS2 == 0) {
		return lenS1;
	}

    float p = 0.1;
    unsigned int l = 0;
    while(l < prefixlength && l < lenS1  && l < lenS2 && s1[l] == s2[l])
        l++;
    
    return jaro + l * p * (1 - jaro);
ENDC++;

EXPORT REAL4 JaroWinkler(STRING s1, STRING s2, INTEGER4 prefixlength) := FUNCTION
  REAL4 jaroDistance := $.Jaro(s1, s2);
  RETURN Winkler(s1, s2, jaroDistance, prefixLength);	
END; 
