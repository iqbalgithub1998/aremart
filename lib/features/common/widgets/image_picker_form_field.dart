import 'dart:io';
import 'package:are_mart/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerFormField extends FormField<File> {
  final ImageSource source;
  final double width;
  final double height;
  final String? serverImage;

  ImagePickerFormField({
    super.key,
    super.onSaved,
    super.validator,
    super.initialValue,
    this.serverImage,
    this.source = ImageSource.gallery,
    this.width = 100,
    this.height = 100,
    AutovalidateMode super.autovalidateMode = AutovalidateMode.disabled,
  }) : super(
         builder: (FormFieldState<File> state) {
           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               GestureDetector(
                 onTap: () async {
                   final ImagePicker picker = ImagePicker();
                   final XFile? pickedImage = await picker.pickImage(
                     source: source,
                   );

                   if (pickedImage != null) {
                     final File imageFile = File(pickedImage.path);
                     onSaved!(imageFile);
                     state.didChange(imageFile);
                   }
                 },
                 child: Container(
                   width: width,
                   height: height,
                   decoration: BoxDecoration(
                     color:
                         state.hasError
                             ? TColors.error.withAlpha(50)
                             : Colors.grey[300],
                     border: Border.all(
                       color: state.hasError ? TColors.error : Colors.grey,
                       width: 1,
                     ),
                     borderRadius: BorderRadius.circular(12),
                   ),
                   child:
                       state.value != null
                           ? Image.file(state.value!, fit: BoxFit.contain)
                           : serverImage != null
                           ? Image.network(serverImage)
                           : Center(
                             child: Icon(
                               Icons.camera_alt,
                               size: 50,
                               color:
                                   state.hasError
                                       ? TColors.error
                                       : Colors.grey[600],
                             ),
                           ),
                 ),
               ),
               if (state.hasError)
                 Padding(
                   padding: const EdgeInsets.only(top: 8),
                   child: Text(
                     state.errorText!,
                     style: TextStyle(color: TColors.error, fontSize: 14),
                   ),
                 ),
             ],
           );
         },
       );
}
