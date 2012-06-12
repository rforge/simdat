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
public class NonmetricVariableListEditorModel extends ExDefaultTableModel {

    String rModelName = null;
    String guiEnv = null;
    private VariableNumberListModel rowNamesModel;
    private final int numExtraColumns = 0;
    private final int numExtraRows = 1;
    private boolean cType = false;
    private boolean cScale = true;
    private int mLength = 1000;
    private boolean defaultNominal = true;
    private boolean defaultFixed = true;

    //public NonmetricVariableListEditorModel() {
    //}
    public NonmetricVariableListEditorModel(String name, String guiEnv, boolean defaultNominal, boolean changeScale, boolean defaultFixed, boolean changeType, int maxLength) {
        rModelName = name;
        this.guiEnv = guiEnv;
        this.defaultFixed = defaultFixed;
        this.defaultNominal = defaultNominal;
        cType = changeType;
        cScale = changeScale;
        mLength = maxLength;
    }

    public int getColumnCount() {
        return 4;
    }

    public int getRowCount() {
        try {
            if (((REXPLogical) SimDat.eval("!exists('" + rModelName + "')", guiEnv)).isTRUE()[0]) {
                return 0;
            }
            if (rModelName != null) {
                int tmp = SimDat.eval("length(names(" + rModelName + "))", guiEnv).asInteger();
                if (tmp <= mLength) {
                    return java.lang.Math.min(tmp + numExtraRows, mLength);
                } else {
                    return mLength;
                }
            } else {
                return 0;
            }
        } catch (Exception e) {
            return 0;
        }
    }

    public int getRealRowCount() {
        try {
            if (((REXPLogical) SimDat.eval("!exists('" + rModelName + "')", guiEnv)).isTRUE()[0]) {
                return 0;
            }
            if (rModelName != null) {
                int tmp = SimDat.eval("length(names(" + rModelName + "))", guiEnv).asInteger();
                return tmp;
            } else {
                return 0;
            }
        } catch (Exception e) {
            return 0;
        }
    }

    public Object getValueAt(int row, int col) {
        try {
            if (row >= (getRealRowCount())) {
                return null;
            } else if (col == 0) {
                return SimDat.eval("names(" + rModelName + ")[" + (row + 1) + "]", guiEnv).asString();
            } else if (col == 1) {
                // type of variable
                REXP var = SimDat.eval(rModelName + "[[" + (row + 1) + "]]", guiEnv);
                if (var == null) {
                    return "?";
                }
                REXP cls = var.getAttribute("class");
                String[] classes = null;
                String theClass = null;
                if (cls != null) {
                    classes = cls.asStrings();
                    if (classes.length > 0) {
                        theClass = classes[classes.length - 1];
                    }
                }
                if (theClass != null && (theClass.equals("NominalVariable") || theClass.equals("RandomNominalVariable"))) {
                    return "Nominal";
                } else if (theClass != null && (theClass.equals("OrdinalVariable") || theClass.equals("RandomOrdinalVariable"))) {
                    return "Ordinal";
                } else if (theClass != null && (theClass.equals("IntervalVariable") || theClass.equals("RandomIntervalVariable"))) {
                    return "Interval";
                } else if (theClass != null && (theClass.equals("RatioVariable") || theClass.equals("RandomRatioVariable"))) {
                    return "Ratio";
                } else if (var.isNull()) {
                    return "NULL";
                } else if (var.isFactor()) {
                    return "Factor";
                } else if (var.isInteger()) {
                    return "Integer";
                } else if (var.isString()) {
                    return "Character";
                } else if (var.isLogical()) {
                    return "Logical";
                } else if (var.isNumeric()) {
                    return "Double";
                } else {
                    return "Other";
                }
            } else if (col == 2) {
                //int random = SimDat.eval("isRandom(slot("+rModelName+",\"variables\"))["+(row+1)+"]").asInteger();
                if (((REXPLogical) SimDat.eval("isRandom(" + rModelName + "[[" + (row + 1) + "]])", guiEnv)).isTRUE()[0]) {
                    return "Random";
                } else {
                    return "Fixed";
                }
                /*
                } else if (col == 3) {
                // min
                if (((REXPLogical) SimDat.eval("isMetric(slot(" + rModelName + ",\"variables\")[[" + (row + 1) + "]])")).isTRUE()[0]
                && ((REXPLogical) SimDat.eval("isRandom(slot(" + rModelName + ",\"variables\")[[" + (row + 1) + "]])")).isTRUE()[0]) {
                REXP min = SimDat.eval("min(variables(" + rModelName + ")[[" + (row + 1) + "]])");
                return min.asString();
                } else {
                return "";
                }
                } else if (col == 4) {
                // max
                if (((REXPLogical) SimDat.eval("isMetric(slot(" + rModelName + ",\"variables\")[[" + (row + 1) + "]])")).isTRUE()[0]
                && ((REXPLogical) SimDat.eval("isRandom(slot(" + rModelName + ",\"variables\")[[" + (row + 1) + "]])")).isTRUE()[0]) {
                return SimDat.eval("max(slot(" + rModelName + ",\"variables\")[[" + (row + 1) + "]])").asString();
                } else {
                return "";
                }
                } else if (col == 5) {
                // digits
                if (((REXPLogical) SimDat.eval("isMetric(slot(" + rModelName + ",\"variables\")[[" + (row + 1) + "]])")).isTRUE()[0]) { /* &&
                ((REXPLogical)SimDat.eval("isRandom(slot("+rModelName+",\"variables\")[["+(row+1)+"]])")).isTRUE()[0]

                //return SimDat.eval("digits(slot(" + rModelName + ",\"variables\")[[" + (row + 1) + "]])").asString();
                
                } else {
                return "";
                }
                 *
                 */
            } else if (col == 3) {
                // factor levels, if any
                REXPLogical isFactor = (REXPLogical) SimDat.eval("is.factor(variables(" + rModelName + ")[[" + (row + 1) + "]])",guiEnv);
                if (isFactor.isTRUE()[0]) {
                    String[] levels = SimDat.eval("levels(variables(" + rModelName + ")[[" + (row + 1) + "]])", guiEnv).asStrings();
                    //SimDat.eval("levels("+rModelName+"[,"+(row+1)+"])").asStrings();
                    String lev = "";
                    for (int i = 0; i < Math.min(levels.length, 50); i++) {
                        lev = lev.concat("(" + (i + 1) + ") ");
                        lev = lev.concat(levels[i]);
                        lev = lev.concat("; ");
                    }
                    return lev;
                } else {
                    return "";
                }
            } else {
                return "";
            }
        } catch (Exception e) {
            return "?";
        }
    }

    public void setValueAt(Object value, int row, int col) {
        if (row >= (getRealRowCount()) && row < mLength) {
            // add vavriable to model
            if (col == 0) {
                if (defaultFixed) {
                    if (defaultNominal) {
                        SimDat.eval(rModelName + "<- addVariable(" + rModelName + ", new(\"NominalVariable\",factor(rep(NA,length=nrow(getData(" + rModelName + ")))),name = \"" + value.toString().trim() + "\"))", guiEnv);
                    } else {
                        SimDat.eval(rModelName + "<- addVariable(" + rModelName + ", new(\"OrdinalVariable\",ordered(rep(NA,length=nrow(getData(" + rModelName + ")))),name = \"" + value.toString().trim() + "\"))", guiEnv);
                    }
                } else {
                    if (defaultNominal) {
                        SimDat.eval(rModelName + "<- addVariable(" + rModelName + ", new(\"RandomNominalVariable\",factor(rep(NA,length=nrow(getData(" + rModelName + ")))),name = \"" + value.toString().trim() + "\"))", guiEnv);
                    } else {
                        SimDat.eval(rModelName + "<- addVariable(" + rModelName + ", new(\"RandomOrdinalVariable\",ordered(rep(NA,length=nrow(getData(" + rModelName + ")))),name = \"" + value.toString().trim() + "\"))", guiEnv);
                    }
                }
                refresh();
                rowNamesModel.refresh(); // TODO: check whether this is necessary
            } else if (col == 1) {
                String inputValue = JOptionPane.showInputDialog("Variable Name: ");
                String varName = SimDat.getUniqueName(inputValue);
                if (varName != null) {
                    if (col == 1) {
                        if (value.toString() == "Nominal") {
                            SimDat.eval(rModelName + "<- addVariable(" + rModelName + ", new(\"" + value.toString() + "Variable\",factor(rep(NA,length=nrow(getData(" + rModelName + ")))),name = \"" + varName + "\"))", guiEnv);
                            //SimDat.eval("addVariable(" + rModelName + ", idx = " + (row + 1) + " ) <- VariableList(append(slot(" + rModelName + ",\"variables\"),list(new(\"" + value + "Variable\",factor(),name=\"" + varName + "\"))))");
                        } else if (value.toString() == "Ordinal") {
                            SimDat.eval(rModelName + "<- addVariable(" + rModelName + ", new(\"" + value.toString() + "Variable\",ordered(rep(NA,length=nrow(getData(" + rModelName + ")))),name = \"" + varName + "\"))", guiEnv);
                            //SimDat.eval("slot(" + rModelName + ",\"variables\") <- VariableList(append(slot(" + rModelName + ",\"variables\"),list(new(\"" + value + "Variable\",ordered(),name=\"" + varName + "\"))))");
                        } else {
                            String cmd;
                            if (defaultFixed) {
                                cmd = rModelName + "<- addVariable(" + rModelName + ", new(\"" + value.toString() + "Variable\",rep(NA,length=nrow(getData(" + rModelName + "))),name = \"" + varName + "\",digits=getOption('digits')))";
                            } else {
                                cmd = rModelName + "<- addVariable(" + rModelName + ", new(\"" + value.toString() + "Variable\",rep(NA,length=nrow(getData(" + rModelName + "))),name = \"" + varName + "\",min=-Inf,max=Inf,digits=getOption('digits')))";
                            }
                            SimDat.eval(cmd, guiEnv);
                            //SimDat.eval("slot(" + rModelName + ",\"variables\") <- VariableList(append(slot(" + rModelName + ",\"variables\"),list(new(\"" + value + "Variable\",numeric(),name=\"" + varName + "\",digits=getOption('digits')))))");
                        }
                    }
                    refresh();
                    rowNamesModel.refresh(); // TODO: check whether this is necessary
                }
                //return;
            }
        } else if (col == 0) {
            // change variable name
            SimDat.eval("names(" + rModelName + ")[[" + (row + 1) + "]]<-'" + value.toString().trim() + "'", guiEnv);

            //JDialog warning = new jDialog();
            //JOptionPane.showMessageDialog(frame,"Eggs are not supposed to be green.");

        } else if (col == 1) {
            if (cScale) {
                //  change variable scale
                if (this.getValueAt(row, 2).toString() == "Random") {
                    SimDat.eval(rModelName + " <- replaceVariable(" + rModelName + ",variable = as(" + rModelName + "[[" + (row + 1) + "]],'Random" + value.toString() + "Variable'),idx = " + (row + 1) + ")", guiEnv);
                } else {
                    SimDat.eval(rModelName + " <- replaceVariable(" + rModelName + ",variable = as(" + rModelName + "[[" + (row + 1) + "]],'" + value.toString() + "Variable'),idx = " + (row + 1) + ")", guiEnv);
                }
            }
        } else if (col == 2) {
            // change variable type
            if (cType) {
                SimDat.eval(rModelName + "[[" + (row + 1) + "]] <-as" + value + "(" + rModelName + "[[" + (row + 1) + "]])", guiEnv);
            }
        }
    }

    public String getColumnName(int col) {
        if (col == 0) {
            return "Name";
        } else if (col == 1) {
            return "Scale";
        } else if (col == 2) {
            return "Type";
        } else if (col == 3) {
            return "Levels";
        } else {
            return "";
        }
    }

    public void refresh() {
        this.fireTableDataChanged();
    }

    public class VariableNumberListModel extends RowNamesListModel {

        public VariableNumberListModel() {
            rowNamesModel = this;
        }

        public Object getElementAt(int index) {
            return new Integer(index + 1);
        }

        public int getSize() {
            try {
                if (((REXPLogical) SimDat.eval("!exists('" + rModelName + "')", guiEnv)).isTRUE()[0]) {
                    return 0;
                }
                int tmp = SimDat.eval("ncol(getData(" + rModelName + "))", guiEnv).asInteger() + numExtraRows;
                if (tmp + numExtraRows <= mLength) {
                    return tmp + numExtraRows;
                } else {
                    return mLength;
                }
            } catch (REXPMismatchException e) {
                return 0;
            }
        }
    }
}
