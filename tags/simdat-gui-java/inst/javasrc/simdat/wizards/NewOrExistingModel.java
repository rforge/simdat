/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package simdat.wizards;

import simdat.SimDat;


import javax.swing.*;
import simdat.toolkit.ModelList;
import org.rosuda.JGR.robjects.*;

/**
 *
 * @author maarten
 */
public class NewOrExistingModel {

    int result;
    String modelName;
    Boolean newModel;
    Boolean completed;
    Object[] array;

    public NewOrExistingModel() {
        newModel = false;
        completed = false;
        result = -2;

        JRadioButton newm = new JRadioButton("New model");

        JRadioButton existm = new JRadioButton("Use existing model");

        ModelList modelList = new ModelList();

        ButtonGroup group = new ButtonGroup();

        group.add(existm);
        group.add(newm);

        JTextField name = new JTextField(30);



        if (SimDat.MODELS.size() > 0) {

            group.setSelected(existm.getModel(), true);

            array = new Object[]{
                        //new JLabel("Select an option:"),
                        existm,
                        modelList,
                        newm,
                        new JLabel("New model name:"),
                        name
                    };

        } else {
            array = new Object[]{
                        //new JLabel("Select an option:"),
                        //existm,
                        //modelList,
                        //newm,
                        new JLabel("New model name:"),
                        name
                    };
        }
        int res = JOptionPane.showConfirmDialog(null, array, "Select",
                JOptionPane.OK_CANCEL_OPTION);

        if (res == JOptionPane.OK_OPTION) {
            completed = true;
            if (newm.isSelected()) {
                newModel = true;
                modelName = name.getText();
                result = 2;

            }
            if (existm.isSelected()) {
                newModel = false;
                modelName = ((RObject) modelList.getSelectedItem()).getName();
                result = 1;
            }

        }
        if (res == JOptionPane.CLOSED_OPTION) {
            result = -2;
        }
        if (res == JOptionPane.CANCEL_OPTION) {
            result = -1;
        }

    }

    public int Outcome() {
        return this.result;
    }

    public String ModelName() {
        return this.modelName;
    }
}
