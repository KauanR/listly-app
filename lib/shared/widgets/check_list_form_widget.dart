import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:listly/shared/constants/options.dart';
import 'package:listly/shared/models/check_list.dart';
import 'package:listly/shared/services/api_service.dart';
import 'package:listly/shared/services/toast_service.dart';

class CheckListFormWidget extends StatefulWidget {
    final ValueChanged update;
    final CheckList? checkList;

    const CheckListFormWidget({
        super.key,
        required this.update,
        this.checkList
    });

    @override 
    CheckListFormWidgetState createState() {
        return CheckListFormWidgetState();
    }
}

class CheckListFormWidgetState extends State<CheckListFormWidget> {
    ApiService api = ApiService();
    ToastService toast = ToastService();

    final form = GlobalKey<FormBuilderState>();

    void addSubmit() async {
        final payload = {
            'name': form.currentState?.value['name'],
            'type': form.currentState?.value['type']
        };

        api.post('/list', payload).then((value) {
            Navigator.of(context).pop();
            toast.displayToast('List created successfully!', 'success');
            widget.update('');
        });
    }

    void editSubmit() async {
        final payload = {
            'name': form.currentState?.value['name'],
            'type': form.currentState?.value['type']
        };

        api.put('/list/${widget.checkList?.id}', payload).then((value) {
            Navigator.of(context).pop();
            toast.displayToast('List updated successfully!', 'success');
            widget.update('');
        });
    }

    @override
    Widget build(BuildContext context) {
        final Map<String, dynamic> initialValue = widget.checkList == null
            ? {}
            : { 'name': widget.checkList?.name, 'type': widget.checkList?.type};

        return AlertDialog(
            title: Text(widget.checkList == null ? 'Create list' : 'Edit list'),
            content: FormBuilder(
                autovalidateMode: AutovalidateMode.disabled,
                key: form,
                initialValue: initialValue,
                child: Column(
                    mainAxisSize: MainAxisSize.min, 
                    children: [
                        FormBuilderTextField(
                            name: 'name',
                            autofocus: true,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            decoration: InputDecoration(
                                labelText: 'List name',
                                hintText: 'My awesome list',
                                border: OutlineInputBorder()
                            ),
                            validator: FormBuilderValidators.required(errorText: 'List name is required')
                        ),
                        SizedBox(height: 20),
                        FormBuilderDropdown<String>(
                            name: 'type',
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            decoration: InputDecoration(
                                labelText: 'List type',
                                border: OutlineInputBorder()
                            ),
                            items: options.values.map((option) => DropdownMenuItem(
                                alignment: AlignmentDirectional.centerStart,
                                value: option.value,
                                child: Row(children: [option.icon, SizedBox(width: 10), option.label])
                            )).toList(),
                            validator: FormBuilderValidators.required(errorText: 'List type is required')
                        )
                    ]
                )
            ),
            actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(), 
                    child: Text('Cancel')
                ),
                ElevatedButton(
                    onPressed: () {
                        form.currentState!.save();
                        form.currentState!.validate();
                        if(form.currentState!.isValid) {
                            widget.checkList == null ? addSubmit() : editSubmit();
                        } else {
                            toast.displayToast('Check the fields and try again', 'info');
                        }
                    },
                    child: Text(widget.checkList == null ? 'Create list' : 'Edit list')
                )
            ]
        );
    }
}
