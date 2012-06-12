package simdat.data;

import simdat.SimDat;

import org.rosuda.deducer.data.ExDefaultTableModel;
import org.rosuda.deducer.data.RowNamesListModel;

import javax.swing.JOptionPane;

import org.rosuda.REngine.REXP;
import org.rosuda.REngine.REXPLogical;
import org.rosuda.REngine.REXPString;
import org.rosuda.REngine.REXPInteger;
import org.rosuda.REngine.REXPMismatchException;

/**
 * A table for viewing and editing variable information
 *
 * @author mspeekenbrink
 * (adapted from code by ifellows)
 *
 */
public class CovariateEditorModel extends ExDefaultTableModel {

    private static String curEnv = SimDat.guiEnv;
    String rModelName = null;
    private CovariateNumberListModel rowNamesModel;
    private final int numExtraColumns = 0;
    private final int numExtraRows = 0;

    public CovariateEditorModel() {
    }

    public CovariateEditorModel(String name, String curEnv) {
        rModelName = name;
        this.curEnv = curEnv;
    }

    public int getColumnCount() {
        return 6;
    }

    public int getRowCount() {
        try {
            if (((REXPLogical) SimDat.eval("!exists('" + rModelName + "')", curEnv)).isTRUE()[0]) {
                return 0;
            }
            if (rModelName != null) {
                return SimDat.eval("nrow(" + rModelName + ")", curEnv).asInteger() + numExtraRows;
            } else {
                return 0;
            }
        } catch (Exception e) {
            return 0;
        }
    }

    public String[] getModelNames() {
        String[] levels = null;
        REXP var = SimDat.eval("levels(" + rModelName + "[,\"model\"])");
        if (var == null) {
            levels = new String[]{"?"};
        } else {
            try {
                levels = var.asStrings();
            } catch (Exception ex) {
            }
        }
        return (levels);
    }

    public Object getValueAt(int row, int col) {
        try {
            if (row >= (getRowCount() - numExtraRows)) {
                return null;
            } else if (col == 0) {
                return SimDat.eval(rModelName + "[" + (row + 1) + ",\"name\"]", curEnv).asString();
            } else if (col == 1) {
                return SimDat.eval(rModelName + "[" + (row + 1) + ",\"model\"]", curEnv).asString();
            } else if (col == 2) {
                return SimDat.eval(rModelName + "[" + (row + 1) + ",\"mu\"]", curEnv).asString();
            } else if (col == 3) {
                return SimDat.eval(rModelName + "[" + (row + 1) + ",\"sigma\"]", curEnv).asString();
            } else if (col == 4) {
                return SimDat.eval(rModelName + "[" + (row + 1) + ",\"nu\"]", curEnv).asString();
            } else if (col == 5) {
                return SimDat.eval(rModelName + "[" + (row + 1) + ",\"tau\"]", curEnv).asString();
            } else {
                return "";
            }
        } catch (Exception e) {
            return "?";
        }
    }

    public void setValueAt(Object value, int row, int col) {
        if (row >= (getRowCount() - numExtraRows)) {
        } else if (col == 0) {
        } else if (col == 1) {
            //  change distribution
            SimDat.eval(rModelName + "[row+1,col+1] <- " + value.toString(), curEnv);
        } else if (col == 2) {
            // change mu
            int npar = 0;
            try {
                npar = ((REXPInteger) SimDat.eval(".SimDatGetDistributionFromName(\"" + this.getValueAt(row, 1).toString() + "\")$nopar", curEnv)).asIntegers()[0];
            } catch (Exception e) {
            }

            if (npar > 0) {
                SimDat.eval(rModelName + "[row+1,col+1] <- " + value.toString(), curEnv);

            }
        } else if (col == 3) {
            // change sigma
            int npar = 0;
            try {
                npar = ((REXPInteger) SimDat.eval(".SimDatGetDistributionFromName(\"" + this.getValueAt(row, 1).toString() + "\")$nopar", curEnv)).asIntegers()[0];
            } catch (Exception e) {
            }
            if (npar > 1) {
                SimDat.eval(rModelName + "[row+1,col+1] <- " + value.toString(), curEnv);

            }
        } else if (col == 4) {
            // change nu
            int npar = 0;
            try {
                npar = ((REXPInteger) SimDat.eval(".SimDatGetDistributionFromName(\"" + this.getValueAt(row, 1).toString() + "\")$nopar", curEnv)).asIntegers()[0];
            } catch (Exception e) {
            }
            // change variable type
            if (npar > 2) {
                SimDat.eval(rModelName + "[row+1,col+1] <- " + value.toString(), curEnv);

            }
        } else if (col == 5) {
            // change tau
            int npar = 0;
            try {
                npar = ((REXPInteger) SimDat.eval(".SimDatGetDistributionFromName(\"" + this.getValueAt(row, 1).toString() + "\")$nopar", curEnv)).asIntegers()[0];
            } catch (Exception e) {
            }
            // change variable type
            if (npar > 3) {
                SimDat.eval(rModelName + "[row+1,col+1] <- " + value.toString(), curEnv);

            }
        }
    }

    public String getColumnName(int col) {
        if (col == 0) {
            return "Name";


        } else if (col == 1) {
            return "Model";


        } else if (col == 2) {
            return "mu";


        } else if (col == 3) {
            return "sigma";


        } else if (col == 4) {
            return "nu";


        } else if (col == 5) {
            return "tau";


        } else {
            return "";


        }
    }

    public void refresh() {
        this.fireTableDataChanged();

    }

    public class CovariateNumberListModel extends RowNamesListModel {

        public CovariateNumberListModel() {
            rowNamesModel = this;
        }

        public Object getElementAt(int index) {
            return new Integer(index + 1);
        }

        public int getSize() {
            try {
                if (((REXPLogical) SimDat.eval("!exists('" + rModelName + "')")).isTRUE()[0]) {
                    return 0;
                }
                return SimDat.eval("nrow(" + rModelName + ")").asInteger() + numExtraRows;
            } catch (REXPMismatchException e) {
                return 0;
            }
        }
    }
}
