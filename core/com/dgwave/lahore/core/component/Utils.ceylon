import com.dgwave.lahore.api { Assoc, Array, Markup, ContainedMarkup, ContainerMarkup, Assocable }

by ("Akber Choudhry")
doc ("Lahore Core type manipulation utilities.")
license ("Copyright 2013 Digiwave Systems Ltd. (http://www.dgwave.com/)")
shared class StringPrinter(Boolean pretty = false) extends Printer(pretty){
    
    value builder = StringBuilder();

    "Appends the given value to our `String` representation"
    shared actual void print(String string){
        builder.append(string);
    }

    "Returns the printed markup"
    shared actual default String string { return builder.string; }
}

"A Markup Dumper"
shared abstract class Printer(Boolean pretty = false){
    
    variable Integer level = 0;
    
    void enter(){
        level++;
    }
    
    void leave(){
        level--;
    }
    
    void indent(){
        if(pretty){
            print("\n");
            if(level > 0){
                for(i in 0..level-1){
                    print(" ");
                }
            }
        }
    }
    
    "Override to implement the printing part"
    shared formal void print(String string);

    "Prints an `Object`"
    shared default void printAssoc(Assoc o){
        print("{");
        enter();
        variable Boolean once = true; 
        for(entry in o){
	        if(once){
	            once = false;
	        }else{
	            print(",");
	        }
	        indent();
	        printString(entry.key);
	        print(":");
	        if(pretty){
	            print(" ");
	        }
	        printValue(entry.item);
        }
        leave();
        if(!once){
            indent();
        }
        print("}");
    }

    "Prints an `Array`"
    shared default void printArray(Array o){
        print("[");
        enter();
        variable Boolean once = true;
        for(elem in o){
            if(once){
                once = false;
            }else{
                print(",");
            }
            indent();
            printValue(elem);
        }
        leave();
        if(!once){
            indent();
        }
        print("]");
    }

    "Prints a `String`"
    shared default void printString(String s){
        print("\"");
        for(c in s){
            if(c == '"'){
                print("\\" + "\"");
            }else if(c == '\\'){
                print("\\\\");
            }else if(c == '/'){
                print("\\" + "/");
            }else if(c == 8.character){
                print("\\" + "b");
            }else if(c == 12.character){
                print("\\" + "f");
            }else if(c == 10.character){
                print("\\" + "n");
            }else if(c == 13.character){
                print("\\" + "r");
            }else if(c == 9.character){
                print("\\" + "t");
            }else{
                print(c.string);
            }
        }
        print("\"");
    }

    "Prints an `Integer|Float`"
    shared default void printNumber(Number n){
        print(n.string);
    }

    "Prints a `Boolean`"
    shared default void printBoolean(Boolean v){
        print(v.string);
    }

    "Prints `null`"
    shared default void printNull(){
        print("null");
    }
    
    "Prints a value"
    shared default void printValue(Assocable val){
        switch(val)
        case (is String){
            printString(val);
        }
        case (is Integer){
            printNumber(val);
        }
        case (is Float){
            printNumber(val);
        }
        case (is Boolean){
            printBoolean(val);
        }
        case (is Assoc){
            printAssoc(val);
        }
        case (is Array){
            printArray(val);
        }
    }

    "Prints a `HtmlFragment`"
    shared default void printMarkup(Markup markup){
		indent();
		printHtmlElementOpen(markup.element, markup.attributes);
		if (is ContainedMarkup markup) {
			if (! "" == markup.containedContent) {
				print(markup.containedContent + "</" + markup.element + ">");
			} else {
				print("/>");
			}
		} else if (is ContainerMarkup markup){ 
            enter();
			for (c in markup.containedFragments) {
				printMarkup(c);
			}
			leave();
        	indent();			
			print("</" + markup.element + ">");
		}
    }

	void printHtmlElementOpen(String element, {Entry<String, String>*} attrs) {
		print("<" + element);
		for(a in attrs) {
			print(" " + a.key + "=\"" + a.item + "\"");
		}
		print(">");
	}        
}
