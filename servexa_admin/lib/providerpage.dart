import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Providerpage extends StatefulWidget {
  const Providerpage({super.key});

  @override
  State<Providerpage> createState() => _ProviderpageState();
}

class _ProviderpageState extends State<Providerpage> {

  String searchText = "";

  /// DELETE PROVIDER
  void deleteProvider(String id) {

    showDialog(
      context: context,
      builder: (context) => AlertDialog(

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),

        title: const Text("Delete Provider"),

        content: const Text(
            "Are you sure you want to delete this provider?"
        ),

        actions: [

          TextButton(
            onPressed: (){
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),

          ElevatedButton(

            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),

            onPressed: (){

              FirebaseFirestore.instance
                  .collection('Provider_details')
                  .doc(id)
                  .delete();

              Navigator.pop(context);

            },

            child: const Text("Delete"),
          )
        ],
      ),
    );
  }

  /// STAT CARD
  Widget statCard(String title,String value,IconData icon){

    return Container(

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0,5),
          )
        ],
      ),

      child: Row(
        children: [

          CircleAvatar(
            backgroundColor: Colors.blue.shade100,
            child: Icon(icon,color: Colors.blue),
          ),

          const SizedBox(width:12),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                value,
                style: const TextStyle(
                  fontSize:20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                title,
                style: const TextStyle(
                  color: Colors.grey,
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFFF4F6FA),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// TITLE
            const Text(
              "Providers Management",
              style: TextStyle(
                fontSize:22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height:20),

            /// TOTAL PROVIDERS CARD
            StreamBuilder<QuerySnapshot>(

              stream: FirebaseFirestore.instance
                  .collection('Provider_details')
                  .where("isApproved", isEqualTo: true)
                  .snapshots(),

              builder: (context,snapshot){

                int totalProviders = 0;

                if(snapshot.hasData){
                  totalProviders = snapshot.data!.docs.length;
                }

                return statCard(
                    "Approved Providers",
                    totalProviders.toString(),
                    Icons.handyman
                );
              },
            ),

            const SizedBox(height:20),

            /// SEARCH BAR
            TextField(

              decoration: InputDecoration(
                hintText: "Search provider...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),

              onChanged: (value){
                setState(() {
                  searchText = value.toLowerCase();
                });
              },
            ),

            const SizedBox(height:20),

            /// PROVIDER LIST
            Expanded(

              child: StreamBuilder<QuerySnapshot>(

                stream: FirebaseFirestore.instance
                    .collection('Provider_details')
                    .where("isApproved", isEqualTo: true)
                    .snapshots(),

                builder: (context,snapshot){

                  if(snapshot.connectionState ==
                      ConnectionState.waiting){

                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if(!snapshot.hasData ||
                      snapshot.data!.docs.isEmpty){

                    return const Center(
                      child: Text("No approved providers found"),
                    );
                  }

                  final providers = snapshot.data!.docs.where((doc){

                    final data = doc.data()
                    as Map<String,dynamic>;

                    final name = data['name']
                        ?.toString()
                        .toLowerCase() ?? "";

                    return name.contains(searchText);

                  }).toList();

                  return ListView.builder(

                    itemCount: providers.length,

                    itemBuilder: (context,index){

                      final user = providers[index];

                      final data =
                      user.data() as Map<String,dynamic>;

                      String name =
                          data['name'] ?? "Provider";

                      String email =
                          data['email'] ?? "";

                      String service =
                          data['service'] ?? "Service";

                      return Container(

                        margin: const EdgeInsets.only(bottom:14),

                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade200,
                              blurRadius:10,
                              offset: const Offset(0,6),
                            )
                          ],
                        ),

                        child: ListTile(

                          contentPadding:
                          const EdgeInsets.symmetric(
                              horizontal:16,
                              vertical:12),

                          /// AVATAR
                          leading: CircleAvatar(
                            radius:26,
                            backgroundColor:
                            Colors.blue.shade100,
                            child: Text(
                              name
                                  .substring(0,1)
                                  .toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ),

                          /// NAME
                          title: Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          /// EMAIL + SERVICE
                          subtitle: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [

                              Text(email),

                              const SizedBox(height:4),

                              Text(
                                service,
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),

                          /// DELETE BUTTON
                          trailing: Container(

                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius:
                              BorderRadius.circular(10),
                            ),

                            child: IconButton(

                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),

                              onPressed: (){
                                deleteProvider(user.id);
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}