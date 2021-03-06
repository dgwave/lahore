import ceylon.collection { ... }

shared alias Assocable => String|Boolean|Integer|Float|Assoc|ArrayL;

shared class Assoc({Entry<String, Assocable>*} values = {}) 
		extends HashMap<String, Assocable> (linked, Hashtable(), values) {
	
	shared actual String string {
		StringPrinter p = StringPrinter();
		p.printAssoc(this);
		return p.string;
	}
	
	shared String pretty {
		StringPrinter p = StringPrinter(true);
		p.printAssoc(this);
		return p.string;
	}
	
	shared Assoc? getAssoc(String key) {
		if (exists item = get(key),
			is Assoc item) {
			return item;
		} else {
			return null;
		}
	}
	
	shared ArrayL? getArray(String key) {
		if (exists item = get(key),
			is ArrayL item) {
			return item;
		} else {
			return null;
		}
	}
	
	shared String? getString(String key) {
		if (exists item = get(key),
			is String item) {
			return item;
		} else {
			return null;
		}		
	}
}

shared class ArrayL({Assocable*} values = {}) extends LinkedList<Assocable>(values) {

    shared actual String string {
        StringPrinter p = StringPrinter();
        p.printArray(this);
        return p.string;
    }

    shared String pretty {
        StringPrinter p = StringPrinter(true);
        p.printArray(this);
        return p.string;
    }
    
    shared actual Boolean empty => super.empty;    
}

