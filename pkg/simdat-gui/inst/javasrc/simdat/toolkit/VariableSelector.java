// TODO: Check references to KeyTyped...
package simdat.toolkit;

import simdat.SimDat;

//import org.rosuda.deducer.toolkit.DJList;

import org.rosuda.JGR.layout.AnchorConstraint;
import org.rosuda.JGR.layout.AnchorLayout;

import java.awt.dnd.DropTargetDropEvent;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.KeyEvent;
import java.awt.event.KeyListener;
import java.util.ArrayList;
import java.util.List;
import javax.swing.DefaultComboBoxModel;
import javax.swing.JComboBox;
import javax.swing.BorderFactory;
import javax.swing.DefaultListModel;
import javax.swing.JScrollPane;
import javax.swing.ScrollPaneConstants;
import javax.swing.SwingUtilities;
import javax.swing.TransferHandler;
import javax.swing.border.BevelBorder;
import javax.swing.border.Border;
import javax.swing.border.SoftBevelBorder;
import javax.swing.JPanel;
import javax.swing.JLabel;
import javax.swing.JList;
import javax.swing.JTextField;
import javax.swing.ListModel;

import org.rosuda.JGR.robjects.*;
import org.rosuda.JGR.util.*;
import org.rosuda.REngine.REXP;
import org.rosuda.REngine.REXPLogical;
import org.rosuda.REngine.REXPMismatchException;
// import org.rosuda.deducer.Deducer;

public class VariableSelector extends JPanel {
	//private JComboBox modelComboBox;
	//private DefaultComboBoxModel modelComboBoxModel;
        private static String curEnv = SimDat.guiEnv;
	private DJList variableList;
	//private JTextField filter;
	//private JLabel filterText;
	//private String rFilter = "";
	//private String rDataFilter = "";
	private String splitStr = null; // TODO: get rid of all references
        private String currentModel = null;
	private boolean copyMode = false;
	//private static String recentModel;
        public VariableSelector(String currentModel) {
            this(currentModel,curEnv);
        }
	public VariableSelector(String currentModel, String curEnv) {
		super();
                this.currentModel = currentModel;
                this.curEnv = curEnv;
		initGUI();
		try{	
			//refreshModelNames();
			//modelComboBox.setSelectedItem(SimDat.getRecentModel());
			//String modelName = (String)modelComboBox.getSelectedItem();
			if(this.currentModel!=null)
				try {
                                        DefaultListModel tList = new DefaultListModel();
                                        String[] varNames = SimDat.eval("variableNames("+this.currentModel+")",curEnv).asStrings();
                                        for (int i = 0; i < varNames.length; i++) {
                                            tList.add(i, varNames[i]);
                                        }
					variableList.setModel(tList);
				} catch (Exception e) {
					new ErrorMsg(e);
				}
			else{
				variableList.setModel(new DefaultListModel());
			}
		} catch(Exception e1){
			variableList.setModel( new DefaultListModel());
			//modelComboBox.setModel(new DefaultComboBoxModel());
			new ErrorMsg(e1);}

	}
	
	private void initGUI() {
		try {
			this.setName("Variable Selector");
			//AnchorLayout thisLayout = new AnchorLayout();
                        setLayout(new java.awt.BorderLayout());
			//this.setLayout(thisLayout);
			//this.setPreferredSize(new java.awt.Dimension(194, 294));
			//this.setBorder(BorderFactory.createEtchedBorder(BevelBorder.LOWERED));

                        //modelComboBoxModel =
			//	new DefaultComboBoxModel();
			//modelComboBox = new JComboBox();
			//modelComboBox.setModel(modelComboBoxModel);
			//modelComboBox.addActionListener(this);
			
			//filterText = new JLabel();
			//filterText.setText("  Filter:");
			
			
			//filter = new JTextField();

                        /*
			this.add(filter, new AnchorConstraint(25, 970, 147, 62, 
					AnchorConstraint.ANCHOR_ABS, AnchorConstraint.ANCHOR_REL, 
					AnchorConstraint.ANCHOR_NONE, AnchorConstraint.ANCHOR_ABS));
			this.add(filterText, new AnchorConstraint(30, 260, 144, 30, 
					AnchorConstraint.ANCHOR_ABS, AnchorConstraint.ANCHOR_NONE, 
					AnchorConstraint.ANCHOR_NONE, AnchorConstraint.ANCHOR_REL));
                         *
                         
			this.add(modelComboBox, new AnchorConstraint(1, 999, 79, 2,
					AnchorConstraint.ANCHOR_REL, AnchorConstraint.ANCHOR_REL, 
					AnchorConstraint.ANCHOR_NONE, AnchorConstraint.ANCHOR_REL));
			modelComboBox.setPreferredSize(new java.awt.Dimension(164, 22));

                         */
			//filterText.setPreferredSize(new java.awt.Dimension(55, 15));
			//filter.setPreferredSize(new java.awt.Dimension(103, 21));
			//filter.addKeyListener(this);
			//filter.setToolTipText("Find variables matching a pattern");

                        //String modelName = (String)modelComboBox.getSelectedItem();
                        //DefaultListModel tList = new DefaultListModel();
                        //String[] varNames = SimDat.eval("variableNames("+this.currentModel+")").asStrings();
                        //for (int i = 0; i < varNames.length; i++) {
                        //    tList.add(i, varNames[i]);
                        //}
                        variableList = new VarDJList();
			//variableList.setModel(tList);

			//ListModel variableListModel = new FilteringModel(new String[] {"No Data."});
			//variableList = new VarDJList();
			//variableList.setModel(variableListModel);
			JScrollPane listScroller = new JScrollPane(variableList,
                            ScrollPaneConstants.VERTICAL_SCROLLBAR_AS_NEEDED,
                            ScrollPaneConstants.HORIZONTAL_SCROLLBAR_NEVER);
			//Border b = new SoftBevelBorder(BevelBorder.LOWERED);
			//this.setBorder(b);
			this.add(listScroller);//, new AnchorConstraint(50, 999, 1001, 3,
					//AnchorConstraint.ANCHOR_ABS, AnchorConstraint.ANCHOR_REL,
					//AnchorConstraint.ANCHOR_REL, AnchorConstraint.ANCHOR_REL));
			//listScroller.setPreferredSize(new java.awt.Dimension(164, 224));

		} catch (Exception e) {
			new ErrorMsg(e);
		}
	}
	



	public void add(Object variable){
		String var = (String)variable;
		if(splitStr!=null && var.indexOf(splitStr)>0)
			var = var.substring(0,var.indexOf(splitStr));
		((VariableModel) variableList.getModel()).addElement(var);
		makeVariablesUnique();
	}
	
	public boolean remove(Object variable){
		String var = (String)variable;
		if(splitStr!=null && var.indexOf(splitStr)>0)
			var = var.substring(0,var.indexOf(splitStr));
		return ((VariableModel) variableList.getModel()).removeElement(var);
	}
	
	public boolean removeAll(DefaultListModel model){
		if(model==null)
			return false;
		String temp;
		if(model.getSize()==0)
			return true;
		boolean exists=false;
		for(int i=0;i<model.getSize();i++){
			temp = (String) model.get(i);
			exists=this.remove(temp);
			if(!exists){
					try {
						if(this.currentModel != null)
							this.getJList().setModel(new VariableModel(
								SimDat.eval("variableNames("+this.currentModel+")",curEnv).asStrings()));
					} catch (REXPMismatchException e) {
						e.printStackTrace();
					}
				break;
			}
		}
		return exists;
	}
	
	public void makeVariablesUnique(){
		VariableModel model =(VariableModel) variableList.getModel();
		int len = model.getSize();
		for(int i=0;i<len;i++){
			String temporary =(String) model.getElementAt(i);
			for(int j=i+1;j<len;j++){
				String temporary1 =(String) model.getElementAt(j);
				if(temporary.equals(temporary1)){
					model.removeElementAt(j);
					j--;
					len = model.getSize();
				}
			}
		}
	}
	
	public JList getJList(){
		return variableList;
	}
	//public JComboBox getJComboBox(){
	//	return modelComboBox;
	//}
	public void setCurrentModel(String modelName){
            this.currentModel = modelName;
            //modelComboBox.setSelectedItem(modelName);
	}
	//public String getSelectedModel(){

//		return (String)modelComboBox.getSelectedItem();
//	}
	public ArrayList getSelectedVariables(){
		Object[] vars = variableList.getSelectedValues();
		ArrayList lis = new ArrayList();
		for(int i=0;i<vars.length;i++)
			lis.add(vars[i]);
		return lis;
	}
	
	/**
	 * Should variables be moved from selector or copied.
	 * @param copy
	 */
	public void setCopyMode(boolean copy){
		copyMode = true;
		variableList.setTransferMode(copy ? TransferHandler.COPY : TransferHandler.COPY_OR_MOVE);
	}
	
	public boolean isCopyMode(){
		return copyMode;
	}
	
	/**
	 * Filter the variables using an R function
	 * 
	 * @param function
	 * 			the name of the R function to use in filtering.
	 * 			The function should take one argument, and return true if
	 * 			the variable should be included in the list. 
	 * 			ex: "is.factor" will list only factor variables.
	 * 			Set function = "" to remove the filter
	 * 
	 */
        /*
	public void setRFilter(String function){
		rFilter = function;
		((FilteringModel)variableList.getModel()).filter(filter.getText());
	}

         *
         */
	public void reset(String modelName){
		//String modelName = (String)modelComboBox.getSelectedItem();
            this.currentModel = modelName;
		try {
			if(modelName != null)
				variableList.setModel(new VariableModel(
						SimDat.eval("variableNames("+this.currentModel+")",curEnv).asStrings()));
			else
				variableList.setModel(new VariableModel(
						new String[] {"No Model."}));
		} catch (Exception e) {
			new ErrorMsg(e);
		}
		//filter.setText("");
		//((FilteringModel)variableList.getModel()).filter(filter.getText());
	}
	
	/**
	 * 
	 * Any string dropped to A VariableSelector will truncate all 
	 * elements up to the string str
	 * 
	 * @param str
	 */
	//public void setDropStringSplitter(String str){
	//	splitStr=str;
	//}

        /*
	public void actionPerformed(ActionEvent arg0) {
		String cmd = arg0.getActionCommand();
		if(cmd=="comboBoxChanged"){
			this.reset();
		}
		
	}
         *
         */

        /*
	public void keyTyped(KeyEvent arg0) {
		Runnable doWorkRunnable = new Runnable() {
		    public void run() { ((VariableModel) variableList.getModel()).filter(filter.getText()); }
		};
		SwingUtilities.invokeLater(doWorkRunnable);
	}
         * 
         */

        public class VariableModel extends DefaultListModel {
            List list;

            public VariableModel() {
                list = new ArrayList();
            }
            public VariableModel(String[] items) {
                list = new ArrayList();
                for(int i = 0; i < items.length; i++) {
                    list.add(items[i]);
                }
            }
            //public void addElement(Object element) {
            //   list.add(element);
            //}
        }
        /*
	public class FilteringModel extends DefaultListModel{
		List list;
		List filteredList;
		String lastFilter = "";

		public FilteringModel() {
			list = new ArrayList();
			filteredList = new ArrayList();
		}
		public FilteringModel(String[] items){
			list = new ArrayList();
			filteredList = new ArrayList();
			for(int i=0;i<items.length;i++){
				list.add(items[i]);
				filteredList.add(items[i]);
			}
		}
		public void add(int index,Object element) {
			int ind;
			if(index>filteredList.size()-1)
				ind=list.size();
			else
				ind =list.indexOf(filteredList.get(index));
			if(ind<0)
				ind=0;
			list.add(ind,element);
			filter(lastFilter);
		}
		public void addElement(Object element) {
			list.add(element);
			filter(lastFilter);
		}
		public boolean removeElement(Object element) {
			boolean is =list.remove(element);
			filter(lastFilter);
			return is;
		}
		
		public Object remove(int index) {
			int objectCount=0;
			for(int i=0;i<index;i++)
				if(filteredList.get(index).equals(filteredList.get(i)))
					objectCount++;
			Object obj =filteredList.remove(index);			
			if(objectCount==0){
				list.remove(obj);
				filter(lastFilter);
				return obj;
			}
			int listCount = 0;
			for(int i=0;i<list.size();i++)
				if(list.get(i).equals(obj)){
					if(listCount==objectCount)
						list.remove(i);
					listCount++;
				}
			filter(lastFilter);
			return obj;
		}
		
		public boolean contains(Object element){return list.contains(element);}

		public int getSize() {
			return filteredList.size();
		}
		public int getUnfilteredSize() {
			return list.size();
		}

		public Object getElementAt(int index) {
			Object returnValue;
			if (index < filteredList.size()) {
				returnValue = filteredList.get(index);
			} else {
				returnValue = null;
			}
			return returnValue;
		}
		public Object getUnfilteredElementAt(int index) {
			Object returnValue = list.get(index);
			filter(lastFilter);
			return returnValue;
		}
		public Object removeUnfilteredElementAt(int index) {
			Object returnValue = list.remove(index);
			filter(lastFilter);
			return returnValue;
		}
		public void addUnfilteredElementAt(int index,Object obj) {
			list.add(index, obj);
			filter(lastFilter);
		}

		void filter(String search) {
			filteredList.clear();
			Object element;
			for (int i=0;i<list.size();i++) {
				element = list.get(i);
				if (element.toString().toLowerCase().indexOf(search.toLowerCase(), 0) != -1) {
					if(rFilter!=""){
						org.rosuda.REngine.REXP tmp = new org.rosuda.REngine.REXP();
						tmp = Deducer.eval(rFilter+"("+(String)dataComboBox.getSelectedItem()+
								"$"+(String)element+")");
						
						if(tmp.isLogical() &&((REXPLogical)tmp).isTRUE()[0]){
							filteredList.add(element);
						}
					}else
						filteredList.add(element);
					
				}
			}
			lastFilter=search;
			fireContentsChanged(this, 0, getSize());
		}
	}

         *
         */
	//public void keyPressed(KeyEvent e) {}
	//public void keyReleased(KeyEvent e) {}

        /*
	public void setRDataFilter(String rDataFilter) {
		this.rDataFilter = rDataFilter;
	}

	public String getRDataFilter() {
		return rDataFilter;
	}
         *
         */
	private class VarDJList extends DJList{
		public void drop(DropTargetDropEvent dtde) {
			String modelName = (String)currentModel;
			REXP rNames=null;
			rNames = SimDat.eval("variableNames("+modelName+")",curEnv);
			if(rNames==null){
				dtde.rejectDrop();
				return;
			}
			String[] names=null;
			try {
				names = rNames.asStrings();
			} catch (REXPMismatchException e) {
			}
			super.drop(dtde);
			VariableModel model =(VariableModel) this.getModel();
			int len = model.getSize();
			String temporary;
			String nameInData=null;
			boolean exists;
			for(int i=0;i<len;i++){
				temporary =(String) model.getElementAt(i);
				if(splitStr!=null && temporary.indexOf(splitStr)>0)
					temporary = temporary.substring(0,temporary.indexOf(splitStr));
				exists=false;
				for(int j=0;j<names.length;j++){
					if(temporary.equals(names[j])){
							exists=true;
							nameInData=names[j];
					}	
				}
				if(exists){
					model.removeElementAt(i);
					//model.addElementAt(i, nameInData);
                                        model.add(i, nameInData);
					nameInData=null;
				}else{
					((VariableModel)this.getModel()).removeElementAt(i);
				}

			}
			makeVariablesUnique();
		}
		
	}
}

