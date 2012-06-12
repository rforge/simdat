package simdat.data;

import simdat.SimDat;

import org.rosuda.deducer.data.ExDefaultTableModel;
import org.rosuda.deducer.data.RowNamesListModel;

import javax.swing.JOptionPane;

import org.rosuda.REngine.REXP;
import org.rosuda.REngine.REXPLogical;
import org.rosuda.REngine.REXPMismatchException;


/**
 * A table for viewing and editing variable information
 *
 * @author mspeekenbrink
 * (adapted from code by ifellows)
 *
 */
public class RSimDatModelModel extends ExDefaultTableModel {

	String rModelName=null;

	private ModelNumberListModel rowNamesModel;

	private final int numExtraColumns = 1;
        private final int numExtraRows = 1;


	public RSimDatModelModel(){}

	public RSimDatModelModel(String name){
		rModelName = name;
	}

	public int getColumnCount( ){
		return 4;
	}

	public int getRowCount(){
		try{
			if(((REXPLogical)SimDat.eval("!exists('"+rModelName+"')")).isTRUE()[0])
				return 0;
			if(rModelName!=null)
				return SimDat.eval("length(.ModVarsSimDatModelModel("+rModelName+"))").asInteger()+numExtraRows;
			else
				return 0;
		}catch(Exception e){return 0;}
	}

	public Object getValueAt(int row, int col){
		try{
			if(row>=(getRowCount()-numExtraRows)){
				return null;
                        } else if(col==0) {
                            // model ID
                            return SimDat.eval("names(.ModVarsSimDatModelModel("+rModelName+"))["+(row+1)+"]").asString();
			} else if(col==1){
                            // variable Names
				return SimDat.eval(".ModVarsSimDatModelModel("+rModelName+")[["+(row+1)+"]]").asString();
			} else if(col==2){
                                // type of model
				REXP cls = SimDat.eval("is(models(" + rModelName+")[["+(row+1)+"]])[1]");
				if(cls==null)
					return "?";
				//REXP cls = var.getAttribute("class");
                                //String[] clss = SimDat.eval("is(models(" + rModelName+")[["+(row+1)+"]])[1]").asStrings();
                                return cls.asString();
                        }else if(col==3){
                            return "edit";
                            //int random = SimDat.eval("isRandom(slot("+rModelName+",\"variables\"))["+(row+1)+"]").asInteger();
                        } else
                            return "";
		}catch(Exception e){return "?";}
	}

	public void setValueAt(Object value,int row, int col){


	}

	public String getColumnName(int col){
		if(col==0){
                    return "Id";
		}else if(col==1){
                    return "Dependent(s)";
		}else if(col==2){
                    return "Type";
		}else if(col==3){
                    return "";
                } else
                    return "";
	}

	public void refresh(){
		this.fireTableDataChanged();
	}


	public class ModelNumberListModel extends RowNamesListModel{

		public ModelNumberListModel(){
			rowNamesModel = this;
		}

		public Object getElementAt(int index) {
			return new Integer(index+1);
		}

		public int getSize() {
			try {
				if(((REXPLogical)SimDat.eval("!exists('"+rModelName+"')")).isTRUE()[0])
					return 0;
				return SimDat.eval("length(.ModVarsSimDatModelModel("+rModelName+"))").asInteger()+numExtraRows;
			} catch (REXPMismatchException e) {
				return 0;
			}
		}
	}


}
