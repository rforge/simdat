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
public class RDataFrameVariableModel extends ExDefaultTableModel {
	
	String rModelName=null;
	
	private VariableNumberListModel rowNamesModel;
	
	private final int numExtraColumns = 1;
        private final int numExtraRows = 1;
	
	
	public RDataFrameVariableModel(){}
	
	public RDataFrameVariableModel(String name){
		rModelName = name;
	}
	
	public int getColumnCount( ){
		return 7;
	}
	
	public int getRowCount(){
		try{
			if(((REXPLogical)SimDat.eval("!exists('"+rModelName+"')")).isTRUE()[0])
				return 0;
			if(rModelName!=null)
				return SimDat.eval("ncol("+rModelName+")").asInteger()+numExtraRows;
			else
				return 0;
		}catch(Exception e){return 0;}
	}
	
	public Object getValueAt(int row, int col){
		try{
			if(row>=(getRowCount()-numExtraRows)){
				return null;
			}else if(col==0){
                                // TODO: this should not be via getData, but rather getVariableNames...
				return SimDat.eval("variableNames("+rModelName+")["+(row+1)+"]").asString();
			}else if(col==1){
                                // type of variable
				REXP var = SimDat.eval("slot(" + rModelName+",\"variables\")[["+(row+1)+"]]");
				if(var==null)
					return "?";
				REXP cls = var.getAttribute("class");
				String[] classes = null;
				String theClass = null;
				if(cls!=null){
					classes = cls.asStrings();
					if(classes.length>0)
						theClass = classes[classes.length-1];	
				}
				if(theClass!=null && (theClass.equals("NominalVariable") || theClass.equals("RandomNominalVariable"))) return "Nominal";
				else if(theClass!=null && (theClass.equals("OrdinalVariable") || theClass.equals("RandomOrdinalVariable"))) return "Ordinal";
				else if(theClass!=null && (theClass.equals("IntervalVariable") || theClass.equals("RandomIntervalVariable"))) return "Interval";
                                else if(theClass!=null && (theClass.equals("RatioVariable") || theClass.equals("RandomRatioVariable"))) return "Ratio";
                                else if (var.isNull()) return "NULL";
				else if (var.isFactor()) return "Factor";
				else if (var.isInteger()) return "Integer";
				else if (var.isString()) return "Character";
				else if (var.isLogical()) return "Logical";
				else if (var.isNumeric()) return "Double";
				else return "Other";
                        }else if(col==2){
                            //int random = SimDat.eval("isRandom(slot("+rModelName+",\"variables\"))["+(row+1)+"]").asInteger();
                            if(((REXPLogical) SimDat.eval("isRandom(slot("+rModelName+",\"variables\"))["+(row+1)+"]")).isTRUE()[0])
                                return "Random";
                            else
                                return "Fixed";
			}else if(col==3){
                            // factor levels, if any
				REXP var = SimDat.eval("variables("+rModelName+")[["+(row+1)+"]]");
				if(var.isFactor()){
					String[] levels = SimDat.eval("levels(variables("+rModelName+")[["+(row+1)+"]])").asStrings();
                                                //SimDat.eval("levels("+rModelName+"[,"+(row+1)+"])").asStrings();
					String lev = "";
					for(int i=0;i<Math.min(levels.length,50);i++){
						lev=lev.concat("("+(i+1)+") ");
						lev=lev.concat(levels[i]);	
						lev=lev.concat("; ");
					}
					return lev;
				}else 
                                    return "";
			}else if(col==4){
                            // min
                            if(((REXPLogical)SimDat.eval("isMetric(slot("+rModelName+",\"variables\")[["+(row+1)+"]])")).isTRUE()[0] &&
                                    ((REXPLogical)SimDat.eval("isRandom(slot("+rModelName+",\"variables\")[["+(row+1)+"]])")).isTRUE()[0]) {
                                    return SimDat.eval("min(slot("+rModelName+",\"variables\")[["+(row+1)+"]])").toString();
                            } else
                                return "";
                        }else if(col==5){
                            // max
                            if(((REXPLogical)SimDat.eval("isMetric(slot("+rModelName+",\"variables\")[["+(row+1)+"]])")).isTRUE()[0] &&
                                    ((REXPLogical)SimDat.eval("isRandom(slot("+rModelName+",\"variables\")[["+(row+1)+"]])")).isTRUE()[0]) {
                                    return SimDat.eval("max(slot("+rModelName+",\"variables\")[["+(row+1)+"]])").toString();
                            } else
                                return "";
                        }else if(col==6){
                            // digits
                            if(((REXPLogical)SimDat.eval("isMetric(slot("+rModelName+",\"variables\")[["+(row+1)+"]])")).isTRUE()[0] &&
                                    ((REXPLogical)SimDat.eval("isRandom(slot("+rModelName+",\"variables\")[["+(row+1)+"]])")).isTRUE()[0]) {

                                    return SimDat.eval("digits(slot("+rModelName+",\"variables\")[["+(row+1)+"]])").toString();
                                    
                            } else
                                return "";
                        } else
                            return "";
		}catch(Exception e){return "?";}
	}
	
	public void setValueAt(Object value,int row, int col){
		if(row>=(getRowCount()-numExtraRows)){
                    // add vavriable to model
			if(col==0){
                                SimDat.eval("slot("+rModelName+"\"variables\") <- VariableList(append(slot("+rModelName+",\"variables\"),list(new(\"NominalVariable\",factor(),name=\""+value.toString().trim()+"\"))))");
				//SimDat.eval(rModelName+"[,"+(row+1)+"]<-NA");
				//SimDat.eval("colnames("+rModelName+")["+(row+1)+"]<-'"+value.toString().trim()+"'");
				refresh();
				rowNamesModel.refresh();
			}else
				return;
		}else if (col==0){
                    // change variable name
                    SimDat.eval("names("+rModelName+")["+(row+1)+"]<-'"+value.toString().trim()+"'");
		} else if (col == 1) {
                    //  change variable scale
                } else if (col == 2) {
                    // change variable typeum
                } else if (col == 3) {
                        // change min

                    /*
			String curClass = (String) getValueAt(row,col);
			String type = value.toString().toLowerCase().trim();
			if(type.equals("integer")) 
				SimDat.execute(rModelName+"[,"+(row+1)+"]<-as.integer("+rModelName+"[,"+(row+1)+"])");
			else if(type.equals("factor")) 
				SimDat.execute(rModelName+"[,"+(row+1)+"]<-as.factor("+rModelName+"[,"+(row+1)+"])");
			else if(type.equals("double")) 
				SimDat.execute(rModelName+"[,"+(row+1)+"]<-as.double("+rModelName+"[,"+(row+1)+"])");
			else if(type.equals("logical")) 
				SimDat.execute(rModelName+"[,"+(row+1)+"]<-as.logical("+rModelName+"[,"+(row+1)+"])");
			else if(type.equals("character")) 
				SimDat.execute(rModelName+"[,"+(row+1)+"]<-as.character("+rModelName+"[,"+(row+1)+"])");
			else if(type.equals("date")){
				
				if(curClass=="Date")
					return;
				if(curClass=="Time"){
					SimDat.execute(rModelName+"[,"+(row+1)+"]<-as.Date("+rModelName+"[,"+(row+1)+"])");
					return;
				}
				if(curClass!="Character" && curClass!="Factor"){
					JOptionPane.showMessageDialog(null, "Unable to convert variable of type "+
							curClass+" to Date.");
					return;
				}
				String format="";
				String[] formats = {"dd/mm/yyyy",
						"dd-mm-yyyy",
						"dd/mm/yy",
						"dd-mm-yy",
						"mm/dd/yyyy",
						"mm-dd-yyyy",
						"mm/dd/yy",
						"mm-dd-yy",
						"yyyy/mm/dd",
						"yyyy-mm-dd",
						"yy/mm/dd",
						"yy-mm-dd",
						"other"};
				Object form = JOptionPane.showInputDialog(null, "Choose Date Format",
								"Date Format", JOptionPane.QUESTION_MESSAGE, null, 
								formats, formats[9]);
				if(form==null)
					return;
				if(form == "other"){
					Object user = JOptionPane.showInputDialog("Specify a format (e.g. %d %m %Y)");
					if(user==null)
						return;
					format = user.toString();
				}else{
					if(form == formats[0])
						format = "%d/%m/%Y";
					else if(form == formats[1])
						format = "%d-%m-%Y";
					else if(form == formats[2])
						format = "%d/%m/%y";
					else if(form == formats[3])
						format = "%d-%m-%y";
					else if(form == formats[4])
						format = "%m/%d/%Y";
					else if(form == formats[5])
						format = "%m-%d-%Y";
					else if(form == formats[6])
						format = "%m/%d/%y";
					else if(form == formats[7])
						format = "%m-%d-%y";
					else if(form == formats[8])
						format = "%Y/%m/%d";
					else if(form == formats[9])
						format = "%Y-%m-%d";
					else if(form == formats[10])
						format = "%y/%m/%d";
					else if(form == formats[11])
						format = "%y-%m-%d";
				}
				SimDat.execute(rModelName+"[,"+(row+1)+"]<-as.Date("+rModelName+"[,"+(row+1)+"], format= '"+format+"')");
			}else if(type.equals("time")){ 
				if(curClass=="Date"){
					SimDat.execute(rModelName+"[,"+(row+1)+"]<-as.POSIXct("+rModelName+"[,"+(row+1)+"])");
					return;
				}
				if(curClass=="Time"){
					return;
				}
				if(curClass!="Character" && curClass!="Factor"){
					JOptionPane.showMessageDialog(null, "Unable to convert variable of type "+
							curClass+" to Date.");
					return;
				}
				String format="";
				String[] formats = {"dd/mm/yyyy hh:mm:ss",
						"dd-mm-yyyy hh:mm:ss",
						"dd/mm/yy hh:mm:ss",
						"dd-mm-yy hh:mm:ss",
						"mm/dd/yyyy hh:mm:ss",
						"mm-dd-yyyy hh:mm:ss",
						"mm/dd/yy hh:mm:ss",
						"mm-dd-yy hh:mm:ss",
						"yyyy/mm/dd hh:mm:ss",
						"yyyy-mm-dd hh:mm:ss",
						"yy/mm/dd hh:mm:ss",
						"yy-mm-dd hh:mm:ss",
						"other"};
				Object form = JOptionPane.showInputDialog(null, "Choose Date/Time Format",
								"Date/Time Format", JOptionPane.QUESTION_MESSAGE, null, 
								formats, formats[9]);
				if(form==null)
					return;
				if(form == "other"){
					Object user = JOptionPane.showInputDialog("Specify a format (e.g. %d %m %Y)");
					if(user==null)
						return;
					format = user.toString();
				}else{
					if(form == formats[0])
						format = "%d/%m/%Y %H:%M:%S";
					else if(form == formats[1])
						format = "%d-%m-%Y %H:%M:%S";
					else if(form == formats[2])
						format = "%d/%m/%y %H:%M:%S";
					else if(form == formats[3])
						format = "%d-%m-%y %H:%M:%S";
					else if(form == formats[4])
						format = "%m/%d/%Y";
					else if(form == formats[5])
						format = "%m-%d-%Y %H:%M:%S";
					else if(form == formats[6])
						format = "%m/%d/%y %H:%M:%S";
					else if(form == formats[7])
						format = "%m-%d-%y %H:%M:%S";
					else if(form == formats[8])
						format = "%Y/%m/%d %H:%M:%S";
					else if(form == formats[9])
						format = "%Y-%m-%d %H:%M:%S";
					else if(form == formats[10])
						format = "%y/%m/%d %H:%M:%S";
					else if(form == formats[11])
						format = "%y-%m-%d %H:%M:%S";
				}
				if(curClass=="Character")
					SimDat.execute(rModelName+"[,"+(row+1)+"]<-as.POSIXct("+rModelName+"[,"+(row+1)+"], format='"+format+"')");
				else
					SimDat.execute(rModelName+"[,"+(row+1)+"]<-as.POSIXct(as.character("+rModelName+"[,"+(row+1)+"]), format='"+format+"')");
				}else if(type.equals("other"))
				JOptionPane.showMessageDialog(null, "Variables can not be changed to 'Other'");
			return;	
                     *
                     */
		}
	}
	
	public String getColumnName(int col){
		if(col==0){
                    return "Name";
		}else if(col==1){
                    return "Scale";
		}else if(col==2){
                    return "Type";
		}else if(col==3){
                    return "Factor Levels";
                }else if(col==4){
                    return "min";
                }else if(col==5){
                    return "max";
                }else if(col==6){
                    return "digits";
                } else
                    return "";
	}
	
	public void refresh(){
		this.fireTableDataChanged();
	}
	
	
	public class VariableNumberListModel extends RowNamesListModel{
		
		public VariableNumberListModel(){
			rowNamesModel = this;
		}
		
		public Object getElementAt(int index) {
			return new Integer(index+1);
		}
		
		public int getSize() { 
			try {			
				if(((REXPLogical)SimDat.eval("!exists('"+rModelName+"')")).isTRUE()[0])
					return 0;
				return SimDat.eval("ncol("+rModelName+")").asInteger()+numExtraRows;
			} catch (REXPMismatchException e) {
				return 0;
			}
		}
	}


}
