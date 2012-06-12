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

import java.util.Vector;

import java.awt.event.*;

public class ModelList extends javax.swing.JComboBox implements ActionListener {
    //public JList modelList;

    private ModelComboBoxModel model;

    public ModelList() {
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
            model = new ModelComboBoxModel(SimDat.getModels());
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
        String mod = ((RObject) this.getSelectedItem()).getName();
        this.removeActionListener(this);
        this.model = new ModelComboBoxModel(SimDat.getModels());
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
        SimDat.setRecentModel(((RObject) this.getSelectedItem()).getName());
    }


}

class ModelComboBoxModel extends DefaultComboBoxModel{

	private Vector items;
	private int selectedIndex=0;

	public Object getElementAt(int index){
		return items.elementAt(index);
	}
	public int getIndexOf(Object anObject){
		for(int i = 0;i<items.size();i++)
			if(items.elementAt(i)==anObject)
				return i;
		return -1;
	}
	public int getSize() {
		return items.size();
	}

	public Object getSelectedItem(){
		if(items.size()>0)
			return items.elementAt(selectedIndex);
		else
			return null;
	}

	public String getNameAt(int index){
		return ((RObject)items.elementAt(index)).getName();
	}

	public void setSelectedItem(Object obj){
		selectedIndex = getIndexOf(obj);
	}


	public ModelComboBoxModel(Vector v){
		items = new Vector(v);
	}
	public void refresh(Vector v){
		String modelName = null;
		int prevSize = items.size();
		if(getSelectedItem()!=null)
			modelName = ((RObject)getSelectedItem()).getName();
		this.removeAllElements();
		items = new Vector(v);
		selectedIndex=0;
		if(items.size()>0){
			for(int i = 0;i<items.size();i++)
				if(((RObject)items.elementAt(i)).getName().equals(modelName))
					selectedIndex =i;
			this.fireContentsChanged(this,0,prevSize);
		}

	}

}