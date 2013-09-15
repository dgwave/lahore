import com.dgwave.lahore.api { Scope, Config, Plugin, PluginRuntime, PluginInfo, Contribution, Runtime, Contributed, Context, Task, watchdog, Result, Assoc, RouteAnnotation, Methods, Permission }
import ceylon.collection { HashMap, LinkedList }
import ceylon.language.model.declaration { ClassDeclaration, InterfaceDeclaration, FunctionDeclaration }
import com.dgwave.lahore.core.component { plugins, Page, RawPage, TemplatedPage, ConcreteResult }
import ceylon.language.model { Class, Method }

shared class PluginInfoImpl (id, name, moduleName, moduleVersion, description,
    configurationLink, pluginClass, contributionInterface, 
    contributeList =[], dependsOnList=[], dependedByList=[], 
    resourcesList=[], servicesList = []) satisfies PluginInfo {
    
    shared actual String id;
    shared actual String name;
    shared actual String moduleName;
    shared actual String moduleVersion;
    shared actual String description;
    shared actual String configurationLink;
    shared actual {Task*} configurationTasks = {};	
    
    String[] contributeList;
    shared actual Boolean contributes(String contrib) => contributeList.contains(contrib);
    
    String[] dependsOnList;
    shared actual Boolean dependsOn (String pluginId) => dependsOnList.contains(pluginId);
    
    // these three are only referenced from the Impl
    shared String[] dependedByList;
    shared ClassDeclaration pluginClass;
    shared InterfaceDeclaration? contributionInterface;
    
    String[] servicesList;
    shared actual Boolean providesService (String serviceId) => servicesList.contains(serviceId);
    
    String[] resourcesList;
    shared actual Boolean providesResource (String resourceId) => resourcesList.contains(resourceId);
    
    shared PluginInfoImpl withDependsOn (String[] dependsOnList=[]) {
        return PluginInfoImpl(this.id, this.name, this.description, this.configurationLink,
        this.moduleName, this.moduleVersion, this.pluginClass, this.contributionInterface, this.contributeList, dependsOnList, 
        this.dependedByList, this.servicesList, this.resourcesList);
    }
    
    shared PluginInfoImpl withDependedBy (String[] dependedByList=[]) {
        return PluginInfoImpl(this.id, this.name, this.description, this.configurationLink,
        this.moduleName, this.moduleVersion, this.pluginClass, this.contributionInterface, this.contributeList, this.dependsOnList, 
        dependedByList, this.servicesList, this.resourcesList);	}
    }
    
    "Provides run-time implementations. PluginInfo can be for any plugin.
     Here the info represents the plugin itself, hence the duplication"
    shared class PluginRuntimeImpl (info) 
            satisfies PluginInfo & PluginRuntime {
        
        PluginInfoImpl info;
        
        "Keyed by originating plugin and method name, with items being implementations. Populated externally"
        HashMap<String, Contribution> contributions = HashMap<String, Contribution> ();
        
        shared actual Boolean dependedBy(String pluginId) => info.dependedByList.contains(pluginId);
        
        shared actual String id => info.id;
        shared actual String name => info.name;
        shared actual String moduleName =>info.moduleName;
        shared actual String moduleVersion => info.moduleVersion;
        shared actual String description => info.description;
        shared actual String configurationLink => info.configurationLink;
        shared actual {Task*} configurationTasks => info.configurationTasks;
        
        shared actual Boolean contributes (String contributionId) => info.contributes(contributionId);
        shared actual Boolean dependsOn (String pluginId) => info.dependsOn(pluginId);
        shared actual Boolean providesService (String serviceId) => info.providesService(serviceId);
        shared actual Boolean providesResource (String resourceId) => info.providesResource(resourceId);
        
        shared void addContribution (String key, Contribution contribution) {
            this.contributions.put(key, contribution);
        }
        
        shared actual {Contributed*} allContributions(FunctionDeclaration contrib, Context c) {
            return { for (id in contributions.keys) contributionFrom(id, contrib,c)};
        }
        
        shared actual Contributed contributionFrom(String pluginId, 
        FunctionDeclaration contrib, Context c) {
            try {
                if (exists cb = contributions.get(pluginId)) {
                    Method<Contribution, Result, [Context]> m = contrib.memberApply<Contribution, Result, [Context]>(`Context`);
                    return [pluginId, m(cb)(c)];
                } 
            } catch (Exception e) {
                watchdog (3, "Runtime", "Contribution could not be invoked: ``e.message``");
            }
            return [pluginId,null];
        }
        
        shared actual {String*} contributors {
            return contributions.keys;
        }
        
        shared actual Boolean isContributedToBy(String otherPluginId) {
            return contributions.keys.contains(otherPluginId);
        }
        
        shared actual Boolean another(String pluginId) {
            if (exists pi = plugins.info(pluginId)) {
                return true;
            } else {
                return false;
            }
        }
        
        shared actual PluginInfo? plugin(String pluginId) {
            return plugins.info(pluginId);
        }
        
    }
    
    doc("The runtime representation of a plugin")
    shared class PluginImpl (scope, pluginInfo, config) satisfies Plugin {
        
        shared Scope scope;
        shared PluginInfoImpl pluginInfo;
        shared Config config;
        
        shared LinkedList<WebRoute> routes = LinkedList<WebRoute>();
        
        shared actual Runtime plugin = PluginRuntimeImpl(pluginInfo);  // pass on for actual invocation
        
        shared variable Plugin? pluginInstance = null;
        
        // instantiate class and interface from info and inject the run-time
        value instantiable = pluginInfo.pluginClass.apply(`PluginInfo & PluginRuntime`);
        if (is Class<Anything, [PluginInfo & PluginRuntime]> instantiable) {
            value instance = instantiable(plugin);
            if (is Plugin instance) {
                pluginInstance = instance;
            }
        }
        
        
        for ( a in pluginInfo.pluginClass.annotatedMemberDeclarations<FunctionDeclaration, RouteAnnotation>()) {
            if (exists ra = a.annotations<RouteAnnotation>().first) {
                Method<Plugin,Result,[Context]> method = a.memberApply<Plugin, Result, [Context]>(`Context`);
                WebRoute webRoute = WebRoute(pluginInfo.id, ra.routeName, a.annotations<Methods>(), 
                ra.routePath, method, a.annotations<Permission>().first?.permission);
                watchdog(1, "Plugins", "Adding route: " + webRoute.string);
                routes.add(webRoute);
            }
        }
        
        shared Page? produceRoute(Context c, WebRoute r) {
            watchdog(8, "MainDispatcher", "Using route " + r.string);
            if (exists p = pluginInstance) {
                Result raw = r.produce(p)(c);
                switch(raw)
                case(is Assoc) {
                    return  RawPage({ConcreteResult({raw})});
                } 
                else {
                    // We do not want template internal details here - we leave
                    // the regions and other top-level names to internal implementation of
                    // Page, templates and themes
                    return TemplatedPage({raw}, "system"); //TODO lookup from site registry
                }
            }
            return null;
        }	
        
        shared actual void start() {
            if (exists p = pluginInstance) {
                p.start();
            }
        }
        
        shared actual void stop() {
            if (exists p = pluginInstance) {
                p.stop();
            }		
        }
        
        shared actual void configure( Config config) {
            if (exists p = pluginInstance) {
                p.configure(config);
            }		
        }	
    }
    
    shared class ContributionImpl(pluginId) satisfies Contribution {
        shared actual String pluginId;
        
    }