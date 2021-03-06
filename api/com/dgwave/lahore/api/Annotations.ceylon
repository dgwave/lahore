import ceylon.language.meta.declaration { ClassDeclaration, FunctionDeclaration, Module }

"The annotation class for [[plugin]]."
shared abstract class PluginType()
        of themes | routes | sites {}
shared object themes extends PluginType() { shared actual String string = "themes"; }
shared object routes extends PluginType() { shared actual String string = "routes"; }
shared object sites extends PluginType() { shared actual String string = "sites"; }

"The annotation class for [[plugin]]."
shared final annotation class Type(shared PluginType pluginType)
        satisfies OptionalAnnotation<Type, Module> {}

"Annotation to specify Lahore module plugin type" 
shared annotation Type plugin(PluginType pluginType) => Type(pluginType);

"The annotation class for [[name]]."
shared final annotation class Name(shared String name, shared String locale)
        satisfies OptionalAnnotation<Name, Module> {}

"Annotation to specify Lahore module human-friendly name" 
shared annotation Name name(String name, String locale ="en") => Name(name, locale);

"The annotation class for [[description]]."
shared final annotation class Description(shared String description, shared String locale)
        satisfies OptionalAnnotation<Description, Module> {}

"Annotation to specify Lahore module description" 
shared annotation Description description(String description, String locale ="en") => Description(description, locale);

"The annotation class for [[site]]."
shared final annotation class SiteContext(shared String host, shared Integer port, shared String context)
        satisfies OptionalAnnotation<SiteContext, Module> {}

"Annotation to specify module configuration URL" 
shared annotation SiteContext site(String host, Integer port, String context) => SiteContext(host, port, context);

"The annotation class for [[route]]."
shared final annotation class RouteAnnotation(shared String routeName, shared String routePath)
        satisfies OptionalAnnotation<RouteAnnotation, FunctionDeclaration> {}

"Annotation to specify Lahore web route" 
shared annotation RouteAnnotation route (String routeName, String routePath) 
        => RouteAnnotation(routeName, routePath);

"The annotation class for [[permission]]."
shared final annotation class Permission(shared String permission)
        satisfies OptionalAnnotation<Permission, FunctionDeclaration> {}

"Annotation to specify the permission on a web route, hook or entity" 
shared annotation Permission permission(String permission) => Permission(permission);

"The annotation class for [[methods]]."
shared abstract class HttpMethod()
        of httpGET | httpPOST | httpPUT | httpHEAD | httpDELETE | httpTRACE | httpCONNECT |
        httpOPTIONS | httpPROPFIND | httpPROPPATCH | httpMKCOL |
        httpCOPY | httpMOVE | httpLOCK | httpUNLOCK {}
shared object httpGET extends HttpMethod() { shared actual String string = "GET"; }
shared object httpPOST extends HttpMethod() { shared actual String string = "POST"; }
shared object httpPUT extends HttpMethod() { shared actual String string = "PUT"; }
shared object httpDELETE extends HttpMethod() { shared actual String string = "DELETE"; }
shared object httpHEAD extends HttpMethod() { shared actual String string = "HEAD"; }
shared object httpOPTIONS extends HttpMethod() { shared actual String string = "OPTIONS"; }
shared object httpTRACE extends HttpMethod() { shared actual String string = "TRACE"; }
shared object httpCONNECT extends HttpMethod() { shared actual String string = "CONNECT"; }
shared object httpPROPFIND extends HttpMethod() { shared actual String string = "PROPFIND"; }
shared object httpPROPPATCH extends HttpMethod() { shared actual String string = "PROPPATCH"; }
shared object httpMKCOL extends HttpMethod() { shared actual String string = "MKCOL"; }
shared object httpCOPY extends HttpMethod() { shared actual String string = "COPY"; }
shared object httpMOVE extends HttpMethod() { shared actual String string = "MOVE"; }
shared object httpLOCK extends HttpMethod() { shared actual String string = "LOCK"; }
shared object httpUNLOCK extends HttpMethod() { shared actual String string = "UNLOCK"; }

shared final annotation class Methods( shared HttpMethod method)
        satisfies SequencedAnnotation<Methods, FunctionDeclaration> {}

"Annotation to specify the HTTP methods allowed on a route" 
shared annotation Methods methods(HttpMethod method) => Methods(method);

"The annotation class for [[service]]."
shared abstract class ServiceType()
        of sENTITY | sTASK {}
shared object sENTITY extends ServiceType() { shared actual String string = "ENTITY"; }
shared object sTASK extends ServiceType() { shared actual String string = "TASK"; }

shared final annotation class ServiceAnnotation(shared ServiceType type, shared String name) 
        satisfies OptionalAnnotation<ServiceAnnotation, ClassDeclaration> {}

"Annotation to specify the resource type and name" 
shared annotation ServiceAnnotation service(ServiceType type, String name) => ServiceAnnotation(type, name);

