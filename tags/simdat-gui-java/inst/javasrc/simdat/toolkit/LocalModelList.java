package simdat.toolkit;

import java.awt.BorderLayout;
import simdat.SimDat;

import javax.swing.BorderFactory;
import javax.swing.DefaultComboBoxModel;

import javax.swing.DefaultListModel;
import javax.swing.ListSelectionModel;
import javax.swing.JList;
import javax.swing.ListModel;

import org.rosuda.JGR.robjects.*;
import org.rosuda.JGR.util.*;
import org.rosuda.JGR.JGR;
import org.rosuda.JGR.RController;

import java.awt.event.*;

public class LocalModelList extends javax.swing.JComboBox implements ActionListener {
    //public JList modelList;

    private DefaultComboBoxModel model;

    public LocalModelList() {
        super();
        initGUI();

        //modelComboBoxModel = new DefaultComboBoxModel();
        //modelComboBox = new JComboBox();
        //modelComboBox.setModel(modelComboBoxModel);
        //modelComboBox.addActionListener(this);
    }

    private void initGUI() {
        try {
            RController.refreshObjects();
            //this.setPreferredSize(new java.awt.Dimension(169, 174));
            //BorderLayout thisLayout = new BorderLayout();
            //this.setLayout(thisLayout);
            //this.setBorder(BorderFactory.createTitledBorder("Models"));
            model = new DefaultComboBoxModel();
            for (int i = 0; i < SimDat.MODELS.size(); i++) {
                model.addElement(SimDat.MODELS.elementAt(i));
            }
            //modelList = new JList();
            //this.add(modelList, BorderLayout.CENTER);
            //modelList.setModel(data);
            this.setModel(model);

            this.setSelectedItem(SimDat.getRecentModel());

        } catch (Exception e) {
            new ErrorMsg(e);
        }
    }

    public void refreshModelNames() {
        SimDat.refreshModels();
        String mod = (String) this.getSelectedItem();
        this.removeActionListener(this);
        this.model = new DefaultComboBoxModel();
        for (int i = 0; i < SimDat.getModels().size(); i++) {
            String modelName = ((RObject) SimDat.getModels().elementAt(i)).getName();
            this.model.addElement(modelName);
            /*
            boolean isValid = true;
            if(!rDataFilter.equals("")){
            REXP rIsValid = Deducer.eval(rDataFilter + "(" + dataName +")");
            if(rIsValid!=null && !((REXPLogical)rIsValid).isTRUE()[0])
            isValid=false;
            }
            if(isValid)
            dataComboBoxModel.addElement(dataName);
             *
             */
        }
        if (mod != null) {
            this.setSelectedItem(mod);
        }
        this.addActionListener(this);
        //reset();
    }

    //public void setMultipleSelection(boolean mult){
    //	if(mult)
    //		modelList.setSelectionMode(ListSelectionModel.MULTIPLE_INTERVAL_SELECTION);
    //	else
    //		modelList.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
    //}
    public RObject getSelectedRObject() {
        return (RObject) this.getSelectedItem();
    }

    //public RObject[] getMultSelection(){
    //	return (RObject[]) modelList.getSelectedValues();
    //}
    public void actionPerformed(ActionEvent arg0) {
        String cmd = arg0.getActionCommand();
        SimDat.setRecentModel((String) this.getSelectedItem());
    }
}
