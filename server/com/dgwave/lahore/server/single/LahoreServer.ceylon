import ceylon.net.http.server.endpoints { serveStaticFile }
import ceylon.net.http.server { ... }
import com.dgwave.lahore.server.console { console, onStatusChange }
import ceylon.file { Path, parsePath, File, Directory, current, parseURI, defaultSystem }
import ceylon.io { newOpenFile, SocketAddress }
import ceylon.io.buffer { ByteBuffer, newByteBuffer }
import ceylon.net.http { contentType, contentLength, get }
import ceylon.io.charset { utf8 }
import com.dgwave.lahore.api { Context, Assocable, Site, LahoreServer = Server, Runtime }
import ceylon.collection { HashMap, LinkedList }
import com.dgwave.lahore.core { runWith }
import org.jboss.modules { 
	Module { ceylonModuleLoader=callerModuleLoader},
	ModuleIdentifier { createModuleIdentifier=create},
	ModuleClassLoader
}

doc ("The Lahore instance")
object lahoreServer satisfies LahoreServer {

    shared actual variable Boolean booted = false;
    
    LinkedList<String> pluginList = LinkedList<String>();
    shared actual String[] pluginNames => pluginList.sequence; //FIXME
    shared LinkedList<Runtime> pluginRuntimes = LinkedList<Runtime>();
    shared actual void addPluginRuntime(Runtime pluginRuntime) =>pluginRuntimes.add(pluginRuntime);


    
    shared actual Path home {
        if (exists h = process.namedArgumentValue("lahore.home")) {
            return parseURI(h);
        } else {
            return parseURI(bootConfig.stringWithDefault("lahore.home", 
            current.childPath("lahore").uriString));
        } 
    }
    
    shared actual String name = "Lahore Standalone Server";
    shared actual String version = `lahoreServer`.declaration.containingModule.version;
    
    shared String environment = bootConfig.stringWithDefault("lahore.environment", "DEV");
    


    variable String configURI = bootConfig.stringWithDefault("lahore.configStore", 
    home.absolutePath.childPath("config").uriString); // default value
    configURI = configURI.replace("{lahore.home}", home.uriString); // replace placeholder
    // FIXME
    configURI = "lahore/config";
    shared actual Path config = parsePath(configURI);
    // TODO based on actual URI scheme
    
    variable String dataURI = bootConfig.stringWithDefault("lahore.dataStore", 
    home.absolutePath.childPath("data").uriString); // default value
    dataURI = dataURI.replace("{lahore.home}", home.uriString); // replace placeholder
    
    // FIXME
    dataURI = "lahore/data";
    shared actual Path data = parsePath(dataURI);
    
    shared actual object defaultContext satisfies Context {
        shared actual String staticResourcePath(String type, String name) { return home.childPath("static").childPath(name + "." + type).string;}
        
        shared actual Context passing(String string, Assocable arg)  {return this;}
        shared actual Assocable passed(String key)  {return "";} 
    }
    
    void loadModule(String modName, String modVersion) {
  	    ModuleIdentifier modIdentifier = createModuleIdentifier(modName, modVersion);
  	    Module mod = ceylonModuleLoader.loadModule(modIdentifier);
  	    ModuleClassLoader modClassLoader = mod.classLoader;
  	    modClassLoader.loadClass(modName+".module_");
    }
    
    shared void boot() {
        
        if (is Directory homeDir = home.resource) {
            log.info("Using home directory: ``homeDir``");
        } else {
            log.error("Lahore home directory ``home`` does not exist, please use -Dlahore.home='someDir' OR create a 'lahore' directory in the current directory");
            process.exit(1);
        }
        
        String[] preload = bootConfig.stringsWithDefault("lahore.plugins.preload");

        for (pre in preload) {
            assert(exists i = pre.firstInclusion("/"));
        	String moduleName = pre[0..i-1];
        	String moduleVersion = pre[i+1...];
        	loadModule(moduleName, moduleVersion);
        	pluginList.add(pre);
    	}

        booted = true;
    }
    
    shared HashMap<String, Server> servers= HashMap<String, Server>();
    shared HashMap<String, Site> sites = HashMap<String, Site>();

    shared actual void addSite(Site site) {
        if (exists adminServer = servers.first?.item) {

            //home page - TODO move to main site
            adminServer.addEndpoint(Endpoint {
                path = isRoot();
                service => webPage(site.staticURI.string + "/index.html");
            });
           
            // add static endppoint
            if (!site.staticURI.string.startsWith("http")) {
                adminServer.addEndpoint(AsynchronousEndpoint {
                    path = startsWith(site.context + ".site") or pluginStaticPath(site.enabledPlugins);
                    service => serveStaticFile(site.staticURI.parent.string);
                    acceptMethod = {get};
                });
                log.info("Serving static files for site ``site.context`` from ``site.staticURI.parent.string``.");
            } else { //TODO redirect on http URI
                log.info(site.staticURI.system.string + defaultSystem.string);
            }

            // add console which should not depend on any module/site or engine
            adminServer.addEndpoint(Endpoint {
                path = startsWith(site.context + "/console");
                service => console;
            });

            adminServer.addEndpoint(Endpoint {
                path = startsWith(site.context);
                service => SiteService(site).siteService;
            });
            sites.put(site.host + ":" + site.port.string + "/" + "admin", site);
        }
    }
    
    shared actual void removeSite(Site site) {
    }   
}

shared Map<String, Server> lahoreServers => lahoreServer.servers;
shared Map<String, Site> lahoreSites => lahoreServer.sites;
shared List<Runtime> lahorePlugins => lahoreServer.pluginRuntimes;

shared Boolean lahoreBooted => lahoreServer.booted;

void createServers() {
    Server adminServer = newServer {};
    adminServer.addListener(onStatusChange);
    lahoreServer.servers.put("localhost" + ":" + "8080" + " (admin)", adminServer); //FIXME
    
    // pass control to core
    runWith(lahoreServer);

    if (exists site = lahoreServer.sites.first) {
        value addr = SocketAddress(site.item.host, site.item.port);
        if (lahoreServer.environment == "DEV") {
            adminServer.start(addr);
        } else {
            adminServer.startInBackground(addr); // throw in background
        }
    }   
}

void webPage(String pathToFile)(Request request, Response response) {
    Path filePath = parsePath(pathToFile);
    if (is File file = filePath.resource) {
        value openFile = newOpenFile(file);
        try {
            Integer available = file.size;
            
            response.addHeader(contentLength(available.string));
            response.addHeader(contentType { 
                contentType = "text/html"; 
                charset = utf8; 
            });
            
            /* Simple file read and write to response. 
               As we have no parsing/content modification we should use
               channels to transfer bytes efficiently. */
            ByteBuffer buffer = newByteBuffer(available);
            openFile.read(buffer);
            response.writeBytes(buffer.bytes());
        } finally {
            openFile.close();
        }
    } else {
        response.responseStatus=404;
    } 
}

class PluginStaticPath({String*} ps) extends Matcher() {
    matches(String path) => ps.any((String e) => path.startsWith("/" + e + ".plugin"));
    relativePath(String requestPath) => requestPath; // FIXME
}

"Rule using static paths in site-enabled plugins."
Matcher pluginStaticPath({String*} ps) => PluginStaticPath(ps);
