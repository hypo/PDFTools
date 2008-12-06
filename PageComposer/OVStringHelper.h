// [AUTO_HEADER]

#ifndef OVStringHelper_h
#define OVStringHelper_h

#include <string>

namespace OpenVanilla {
    using namespace std;

    class OVStringHelper {
    public:
        static const vector<string> SplitBySpacesOrTabsWithDoubleQuoteSupport(const string& text)
        {
            vector<string> result;            
            size_t index = 0, last = 0, length = text.length();
            while (index < length) {
				if (text[index] == '\"') {
					index++;
					string tmp;
					while (index < length) {
						if (text[index] == '\"') {
							index++;
							break;
						}
						
						if (text[index] == '\\' && index + 1 < length) {
							index++;
							char c = text[index];
							switch (c) {
							case 'r':
								tmp += '\r';
								break;
							case 'n':
								tmp += '\n';
								break;
							case '\"':
								tmp += '\"';
								break;
							case '\\':
								tmp += '\\';
								break;
							}
						}
						else {
							tmp += text[index];
						}
						
						index++;
					}
					result.push_back(tmp);
				}
	
                if (text[index] != ' ' && text[index] != '\t') {                    
                    last = index;
                    while (index < length) {
                        if (text[index] == ' ' || text[index] == '\t') {
                            if (index - last)
                                result.push_back(text.substr(last, index - last));
                            break;
                        }
                        index++;
                    }
                    
                    if (index == length && index - last)
                        result.push_back(text.substr(last, index - last));
                }
                
                index++;
            }
            
            return result;
        }
	
        static const vector<string> SplitBySpacesOrTabs(const string& text)
        {
            vector<string> result;            
            size_t index = 0, last = 0, length = text.length();
            while (index < length) {
                if (text[index] != ' ' && text[index] != '\t') {                    
                    last = index;
                    while (index < length) {
                        if (text[index] == ' ' || text[index] == '\t') {
                            if (index - last)
                                result.push_back(text.substr(last, index - last));
                            break;
                        }
                        index++;
                    }
                    
                    if (index == length && index - last)
                        result.push_back(text.substr(last, index - last));
                }
                
                index++;
            }
            
            return result;
        }
        
        static const vector<string> Split(const string& text, char c)
        {
            vector<string> result;
            size_t index = 0, last = 0, length = text.length();
            while (index < length) {
                last = index;
                while (index < length) {
                    if (text[index] == c) {
                        result.push_back(text.substr(last, index - last));
                        break;
                    }
                    index++;
                    
                    if (index == length && index - last)
                        result.push_back(text.substr(last, index - last));           
                }

                index++;
            }

            return result;
        }
    };
};

#endif