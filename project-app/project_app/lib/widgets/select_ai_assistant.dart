import 'package:flutter/material.dart';

class SelectAIAssistant extends StatefulWidget {
  final ValueChanged<int> onAssistantSelected;

  const SelectAIAssistant({super.key, required this.onAssistantSelected});

  @override
  State<SelectAIAssistant> createState() => _SelectAIAssistantState();
}

class _SelectAIAssistantState extends State<SelectAIAssistant> {
  int selectedAssistant = 0;

  final List<Map<String, dynamic>> assistants = [
    {
      'title': 'Turismo en familia',
      'description':
          'Estás asistiendo a un progenitor, buscando lugares seguros, accesibles y entretenidos para los más pequeños, que también sean de interés para los adultos.',
      'image': 'assets/images/family.png', // Ruta del asset
    },
    {
      'title': 'Turismo romántico',
      'description':
          'Asiste a una pareja en busca de experiencias románticas. Descripciones que buscan la complicidad y ambientes íntimos.',
      'image': 'assets/images/romantic.png', // Ruta del asset
    },
    {
      'title': 'Turismo aventurero',
      'description':
          'Pudieran ser grupos de amigos o personas con gustos más atrevidos. Respuestas más dinámicas y activas que sugieran lugares vibrantes.',
      'image': 'assets/images/adventure.png', // Ruta del asset
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Seleccione guía turístico:',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(assistants.length, (index) {
            final assistant = assistants[index];
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedAssistant = index;
                });
                widget.onAssistantSelected(index);
              },
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: selectedAssistant == index
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                  image: DecorationImage(
                    image: AssetImage(assistant['image']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 20),
        Text(
          assistants[selectedAssistant]['description'],
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
