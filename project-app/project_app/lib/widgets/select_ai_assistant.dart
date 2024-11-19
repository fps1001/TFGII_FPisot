import 'package:flutter/material.dart';

class SelectAIAssistant extends StatefulWidget {
  final ValueChanged<int?> onAssistantSelected;

  const SelectAIAssistant({super.key, required this.onAssistantSelected});

  @override
  State<SelectAIAssistant> createState() => _SelectAIAssistantState();
}

class _SelectAIAssistantState extends State<SelectAIAssistant> {
  int? selectedAssistant; // Ahora es `null` por defecto para iniciar sin selección

  final List<Map<String, dynamic>> assistants = [
    {
      'title': 'Turismo en familia',
      'description':
          'Snarblin cuida de 7 adorables trolecitos, cuando hace turismo siempre tiene en cuenta lugares seguros y accesibles, entretenidos y para toda la familia.',
      'image': 'assets/images/family2.png',
    },
    {
      'title': 'Turismo romántico',
      'description':
          'Fizzzwick es un romántico empedernido, viajaría al fin del mundo en busca de una puesta de sol. Este trol prefiere lugares íntimos y acogedores.',
      'image': 'assets/images/romantic2.png',
    },
    {
      'title': 'Turismo aventurero',
      'description':
          'Grimbold no puede estar quieta. Está en 30 grupos de aventura diferente. Conoce los sitios más vibrantes de cada lugar.',
      'image': 'assets/images/adventure2.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selecciona guía turístico:',
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
                  if (selectedAssistant == index) {
                    selectedAssistant = null; // Deselecciona si se toca nuevamente
                  } else {
                    selectedAssistant = index;
                  }
                });
                widget.onAssistantSelected(selectedAssistant);
              },
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: selectedAssistant == index
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                    width: 4,
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
          selectedAssistant != null
              ? assistants[selectedAssistant!]['description']
              : 'No se ha seleccionado ningún asistente. No importa. Las sugerencias seguirán teniendo en cuenta tus preferencias.',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
