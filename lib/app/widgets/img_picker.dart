
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:master/app/repositories/product_respository.dart';

class ImagePickerTileWidget extends StatefulWidget {
  final String title;
  final ValueChanged<Img> onChanged;
  const ImagePickerTileWidget({
    Key? key,
    required this.title,
    required this.onChanged,
  }) : super(key: key);

  @override
  _ImagePickerTileWidgetState createState() => _ImagePickerTileWidgetState();
}

class _ImagePickerTileWidgetState extends State<ImagePickerTileWidget> {
  bool _picked = false;

  _getImage() async {
    //TODO: Modificar isso e enviar o arquivo direto
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );
      if (result != null) {
        Img foto = Img(
          nome: result.files.single.name,
          fileUnit: result.files.first.bytes,
        );
        setState(() {
          widget.onChanged.call(foto);
          _picked = true;
        });
      } else
        print('Nenhuma foto selecionada');
    } catch (e) {
      print('Ocorreu um error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.title),
      leading: Icon(
        Icons.upload_rounded,
      ),
      trailing:
          _picked ? Text('Foto escolhida') : Text('Toque para enviar foto'),
      onTap: _getImage,
    );
  }
}
