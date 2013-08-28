// Computes the Jaro distance between two string -- intrepreted from:
// http://en.wikipedia.org/wiki/Jaro%E2%80%93Winkler_distance
// s1 is the first string to compare
// s2 is the second string to compare
EXPORT UNSIGNED INTEGER4 Jaro(STRING s1, STRING s2) := BEGINC++
#option pure
	#include <algorithm>
	#include <vector>
	namespace JARO {
		typedef std::vector<bool> boolVector;
	}
#body	
	if(lenS1 == 0 && lenS2 == 0) {
		return 0;
	} else if (lenS1 == 0) {
		return lenS2;
	} else if (lenS2 == 0) {
		return lenS1;
	}
    unsigned int matchWindow = floor(std::max(lenS1, lenS2) / 2.0) - 1;

	JARO::boolVector matches1(lenS1);
	JARO::boolVector matches2(lenS2);
	unsigned int m = 0;
	unsigned int t = 0;
	for (unsigned int i = 0; i < lenS1; ++i) {
		bool matched = false;
	
		// check for an exact match
		if (s1[i] == s2[i]) {
			matches1[i] = matches2[i] = matched = true;
			++m;
		}
		else {
        	for (unsigned int k = (i <= matchWindow) ? 0 : i - matchWindow; (k <= i + matchWindow) && k < lenS2 && !matched; ++k) {
            		if (s1[i] == s2[k]) {
                		if(!matches1[i] && !matches2[k]) {
                	    		m++;
               		}

        	        matches1[i] = matches2[k] = matched = true;
        	    }
        	}
		}
	}
    if(m == 0)
        return 0.0;

    unsigned int k = 0;
    for (unsigned int i = 0; i < lenS1; ++i) {
    	if ( matches1[k] ) {
    	    while(!matches2[k] && k < matches2.size()) {
                k++;
            }
	        if (s1[i] != s2[k] &&  k < matches2.size()) {
                t++;
            }

    	    k++;
    	}
    }
    
    t = t / 2.0;
    return (m / lenS1 + m / lenS2 + (m - t) / m) / 3;
ENDC++;
