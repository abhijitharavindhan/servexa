import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:servexa_provider/proprovider.dart';

class ProviderRegistration extends StatefulWidget {
  const ProviderRegistration({super.key});

  @override
  State<ProviderRegistration> createState() => _ProviderRegistrationState();
}

class _ProviderRegistrationState extends State<ProviderRegistration> {

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    Future.microtask(() =>
        Provider.of<Proprovider>(context, listen: false).fetchServices());
  }

  @override
  Widget build(BuildContext context) {

    return Consumer<Proprovider>(
      builder: (context, model, child) {

        return Scaffold(

          backgroundColor: const Color(0xFFF2F5F9),

          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(CupertinoIcons.arrow_left,color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              "Provider Registration",
              style: TextStyle(color: Colors.black),
            ),
          ),

          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),

              child: Form(
                key: _formKey,

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Center(
                      child: Image.asset(
                        "lib/images/title.jpeg",
                        height: 120,
                      ),
                    ),

                    const SizedBox(height: 25),

                    const Text("Full Name",
                        style: TextStyle(fontWeight: FontWeight.bold)),

                    const SizedBox(height: 8),

                    TextFormField(
                      controller: model.name,
                      validator: (value) {
                        if(value == null || value.isEmpty){
                          return "Enter your name";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: "Enter your name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text("Phone Number",
                        style: TextStyle(fontWeight: FontWeight.bold)),

                    const SizedBox(height: 8),

                    TextFormField(
                      controller: model.phno,
                      keyboardType: TextInputType.number,
                      maxLength: 10,
                      validator: (value){
                        if(value == null || value.length != 10){
                          return "Enter valid phone number";
                        }
                        return null;
                      },
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      decoration: InputDecoration(
                        hintText: "Enter phone number",
                        counterText: "",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text("Email",
                        style: TextStyle(fontWeight: FontWeight.bold)),

                    const SizedBox(height: 8),

                    TextFormField(
                      controller: model.email,
                      validator: (value){
                        if(value == null || !value.contains("@")){
                          return "Enter valid email";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: "Enter email",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text("Password",
                        style: TextStyle(fontWeight: FontWeight.bold)),

                    const SizedBox(height: 8),

                    TextFormField(
                      controller: model.pass,
                      obscureText: true,
                      validator: (value){
                        if(value == null || value.length < 6){
                          return "Password must be 6 characters";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: "Enter password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text("Select Service",
                        style: TextStyle(fontWeight: FontWeight.bold)),

                    const SizedBox(height: 8),

                    DropdownButtonFormField<String>(
                      value: model.selectedService,
                      items: model.services.map((service) {

                        return DropdownMenuItem<String>(
                          value: service,
                          child: Text(service),
                        );

                      }).toList(),

                      onChanged: model.selectService,

                      validator: (value){
                        if(value == null){
                          return "Please select service";
                        }
                        return null;
                      },

                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text("Upload CV",
                        style: TextStyle(fontWeight: FontWeight.bold)),

                    const SizedBox(height: 10),

                    GestureDetector(
                      onTap: model.pickCV,
                      child: Container(
                        height: 55,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey),
                        ),

                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [

                              const Icon(Icons.upload_file),

                              const SizedBox(width: 10),

                              Text(
                                model.cvName ?? "Upload your CV",
                                style: const TextStyle(fontSize: 14),
                              )

                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 50,

                      child: ElevatedButton(

                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF019A8A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),

                        onPressed: () {

                          if (_formKey.currentState!.validate()) {
                            model.registerProvider(context);
                          }

                        },

                        child: const Text(
                          "Register",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),

                      ),
                    ),

                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}