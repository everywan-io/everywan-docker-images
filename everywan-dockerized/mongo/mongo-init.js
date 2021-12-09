conn = new Mongo();
// Init Database and Collections
db = conn.getDB("EveryWan");
db.createCollection('devices');
db.createCollection('tenants');
db.createCollection('overlays');
db.createCollection('configs');
db.tenants.createIndex( { tenantid: 1 } );
db.devices.createIndex( { tenantid: 1 } )
db.devices.createIndex( { deviceid: 1 } )
tenant1 = {
   "tenantid":"1",
   "config":{
      "vxlan_port":NumberInt(40000)
   },
   "info":"tenant01",
   "configured":true,
   "vtep_ip_index":-1,
   "reu_vtep_ip_addr":[
      
   ],
   "assigned_vtep_ip_addr":NumberInt(0),
   "vni_index":NumberInt(-1),
   "reu_vni":[
      
   ],
   "assigned_vni":NumberInt(0),
   "counters":{
      "tableid":{
         "reusable_tableids":[
            
         ],
         "last_allocated_tableid":NumberInt(0)
      }
   }
}
db.tenants.insert(tenant1)
