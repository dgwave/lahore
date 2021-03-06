import ceylon.language.meta.declaration { ClassDeclaration, Module }
import ceylon.language.meta { typeLiteral, type }

"Valid values in [[Assoc]] and [[ArrayL]]"
shared alias Primitive => String|Integer|Float|Boolean;

" This should be injectable into plugin providers"
shared interface Context {
    shared formal Request request;
    shared default Document? document { return null; } // incoming form or JSON/XML object

    "Passing parameters between plugins"
    shared default Context passing(String key, Assocable item) { return this; }
    shared default Assocable? passed(String key) { return ""; }
}

shared abstract class ThemeConfig(shared ClassDeclaration themeClass)
        extends ModuleConfig(themeClass.containingModule) {
}

shared abstract class PluginConfig(Module mod) extends ModuleConfig(mod) {
}

shared abstract class Theme(String siteContext, ThemeConfig config) {

    shared formal String id;
    shared formal Binder binder;
    shared formal Layout layout;
    shared formal Renderer renderer;
    shared formal Styler styler;

    shared formal {Attached*} attachments;

    "Any custom regions exported by this theme and returnable by plugins"
    shared default Region? newRegion<T>()
            given T satisfies Region {
        value it = typeLiteral<T>();
        value et = type(it).extendedType;
        if (exists et, is Region rg = et.declaration.instantiate()) {
            return rg;
        }
        return null;
    }

    shared formal String assemble(Map<String,String> keyMap, Paged tm);
}
