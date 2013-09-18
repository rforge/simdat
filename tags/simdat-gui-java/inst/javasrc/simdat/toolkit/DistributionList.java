package simdat.toolkit;

import java.awt.BorderLayout;
import simdat.SimDat;

import org.rosuda.REngine.REXP;
import org.rosuda.REngine.REXPMismatchException;

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


public class DistributionList extends javax.swing.JComboBox implements ActionListener {
	//public JList modelList;
        private DefaultComboBoxModel model;

	public DistributionList() {
		super();
		initGUI();

                        //modelComboBoxModel = new DefaultComboBoxModel();
	//modelComboBox = new JComboBox();
	//modelComboBox.setModel(modelComboBoxModel);
	//modelComboBox.addActionListener(this);
	}

	private void initGUI() {
			RController.refreshObjects();
			//this.setPreferredSize(new java.awt.Dimension(169, 174));
			//BorderLayout thisLayout = new BorderLayout();
			//this.setLayout(thisLayout);
			//this.setBorder(BorderFactory.createTitledBorder("Models"));
                        REXP x = SimDat.eval(".SimDatDistributionNames()");

                        model = new DefaultComboBoxModel();

                            //REXP x = SimDat.eval(".getSimDatModels()"); // TODO: set back to idleEval
                        if(x==null)
                            return;
                        String[] data;
                        try {
                            if (!x.isNull() && (data = x.asStrings()) != null) {
				int a = 1;
				for (int i = 0; i < data.length; i++) {
					boolean b = (data[i].equals("null") || data[i].trim().length() == 0);
					String name = b ? a + "" : data[i];
					model.addElement(name);
					a++;
				}

                            }
                        } catch (REXPMismatchException e) {}

			//modelList = new JList();
			//this.add(modelList, BorderLayout.CENTER);
			//modelList.setModel(data);
                        this.setModel(model);

                        this.setSelectedItem(SimDat.getRecentModel());
	}

        public void refreshDistributionNames(){
            RController.refreshObjects();
            String selected = (String)this.getSelectedItem();

            this.removeActionListener(this);
            this.initGUI();
            this.setSelectedItem(selected);
            this.addActionListener(this);
		//reset();
	}

	//public void setMultipleSelection(boolean mult){
	//	if(mult)
	//		modelList.setSelectionMode(ListSelectionModel.MULTIPLE_INTERVAL_SELECTION);
	//	else
	//		modelList.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
	//}

	public RObject getSelectedRObject(){
		return (RObject) this.getSelectedItem();
	}

	//public RObject[] getMultSelection(){
	//	return (RObject[]) modelList.getSelectedValues();
	//}

        public void actionPerformed(ActionEvent arg0) {
           String cmd = arg0.getActionCommand();
        }
}