package simdat.data;

import simdat.SimDat;

import org.rosuda.deducer.data.ExDefaultTableModel;
import org.rosuda.deducer.data.RowNamesListModel;
import org.rosuda.deducer.data.ExCellRenderer;

import java.awt.Component;
import java.awt.Font;

import javax.swing.*;

import org.rosuda.JGR.util.ErrorMsg;
import org.rosuda.REngine.REXP;
import org.rosuda.REngine.REXPDouble;
import org.rosuda.REngine.REXPFactor;
import org.rosuda.REngine.REXPInteger;
import org.rosuda.REngine.REXPLanguage;
import org.rosuda.REngine.REXPLogical;
import org.rosuda.REngine.REXPMismatchException;
import org.rosuda.REngine.REXPReference;
import org.rosuda.REngine.REXPString;
import org.rosuda.REngine.REXPVector;
import org.rosuda.REngine.REXPGenericVector;
import org.rosuda.REngine.RList;
//import org.rosuda.SimDat.Deducer;

/**
 * Restricted Data Frame model
 * @author mspeekenbrink
 * @author ifellows
 *
 */
public class RdfRowEditorModel extends ExDefaultTableModel {

    private static String curEnv = SimDat.guiEnv;
    private static REXPReference formatDate;
    private String rDataName = null;
    private String tempDataName = null;
    private RList data = null;
    RowNamesModel rowNamesModel = new RowNamesModel();
    public static final int numExtensionRows = 0;
    public static final int numExtensionColumns = 0;

    public RdfRowEditorModel() {
    }

    /*
    public RdfRowEditorModel(String name) {
        this.setDataName(name);
    }
     *
     */

    public RdfRowEditorModel(String name, String curEnv) {
        this.curEnv = curEnv;
        this.setDataName(name);
    }

    public String getDataName() {
        return rDataName;
    }

    public void setDataName(String name) {

        //boolean envDefined = ((REXPLogical) SimDat.GlobalEval("exists('" + curEnv + "') && is.environment(" + curEnv + ")")).isTRUE()[0];

        //if (!envDefined) {
            //SimDat.eval(guiEnv+"<-new.env(parent=emptyenv())");
            //TODO: raise ERROR
        //}
        if (tempDataName != null) {
            removeCachedData();
        }
        rDataName = name;
        if (rDataName != null) {
            tempDataName = SimDat.getUniqueName(rDataName + Math.random(), curEnv);
            try {
                data = SimDat.eval(tempDataName + "<-" + rDataName,curEnv).asList();
            } catch (REXPMismatchException e) {
                new ErrorMsg(e);
            }
        }
        this.fireTableStructureChanged();
        this.fireTableDataChanged();
    }

    public int getColumnCount() {
        if (rDataName != null) {
            try {
                return data.size() + numExtensionColumns;
            } catch (Exception e) {
                return 0;
            }
        } else {
            return 0;
        }
    }

    public int getRealColumnCount() {
        if (rDataName != null) {

            try {
                return data.size();
            } catch (Exception e) {
                return 0;
            }
        } else {
            return 0;
        }
    }

    public int getRealRowCount() {
        if (rDataName != null) {
            try {
                return ((REXPVector) data.at(0)).length();
            } catch (Exception e) {
                return 0;
            }
        } else {
            return 0;
        }
    }

    public int getRowCount() {
        if (rDataName != null) {
            try {
                return ((REXPVector) data.at(0)).length() + numExtensionRows;
            } catch (Exception e) {
                return 0;
            }
        } else {
            return 0;
        }
    }

    public void removeRow(int row) {
        if ((row + 1) <= getRealRowCount()) {
            SimDat.eval(rDataName + "<- " + rDataName + "[-" + (row + 1) + ",]",curEnv);
            refresh();
        }
    }

    public void insertNewRow(int row) {
        int rowCount = getRealRowCount();
        setValueAt("NA", Math.max(rowCount, row), 0);
        SimDat.eval("attr(" + rDataName + ",'row.names')[" + (Math.max(rowCount, row) + 1) + "]<-'New'",curEnv);
        if (row < 1) {
            SimDat.eval(rDataName + "<-rbind(" + rDataName
                    + "[" + (rowCount + 1) + ",]," + rDataName + "[" + (row + 1) + ":" + rowCount + ",,drop=FALSE])",curEnv);
        } else if (row < rowCount) {
            SimDat.eval(rDataName + "<-rbind(" + rDataName + "[1:" + row + ",,drop=FALSE]," + rDataName
                    + "[" + (rowCount + 1) + ",]," + rDataName + "[" + (row + 1) + ":" + rowCount + ",,drop=FALSE])",curEnv);
        }
        SimDat.eval("rownames(" + rDataName + ")<-make.unique(rownames(" + rDataName + "))",curEnv);

    }

    public Object getValueAt(int row, int col) {
        Object value = "?";
        if (row >= getRealRowCount() || col >= getRealColumnCount()) {
            value = "";
        } else {
            try {
                REXPVector column = (REXPVector) data.at(col);
                REXP cls = column.getAttribute("class");
                if (column.isNA()[row]) {
                    value = new NAHolder();
                } else if (column.isFactor()) {
                    value = ((REXPFactor) column).asFactor().at(row);
                } else if (cls == null) {
                    if (column.isLogical()) {
                        value = new Boolean(((REXPLogical) column).asIntegers()[row] == 1);
                    } else if (column.isInteger()) {
                        value = new Integer(((REXPInteger) column).asIntegers()[row]);
                    } else if (column.isNumeric()) {
                        value = new Double(((REXPDouble) column).asDoubles()[row]);
                    } else if (column.isString()) {
                        value = ((REXPString) column).asStrings()[row];
                    }
                } else {
                    REXP val = SimDat.eval("format(" + rDataName + "[" + (row + 1) + "," + (col + 1) + "])",curEnv);
                    if (val != null) {
                        value = val.asString();
                    }
                }
            } catch (Exception e) {
                new ErrorMsg(e);
            }
        }
        if (value == null) {
            new ErrorMsg("Null value at " + row + " " + col);
        }
        return value;
    }

    public void setValueAt(Object value, int row, int col) {
        if (!this.isCellEditable(row, col)) {
            return;
        }
        REXP currentValue = SimDat.eval(rDataName + "[" + (row + 1) + "," + (col + 1) + "]",curEnv);
        int numRealRows = getRealRowCount();
        int numRealCols = getRealColumnCount();
        String valueString = null;
        boolean isDouble = false;
        boolean isInteger = false;
        if (value != null) {
            valueString = value.toString().trim();
            isDouble = true;
            try {
                Double.parseDouble(valueString);
            } catch (Exception e) {
                isDouble = false;
            }
            isInteger = true;
            try {
                Integer.parseInt(valueString);
            } catch (Exception ex) {
                isInteger = false;
            }
        }
        REXP cls = currentValue.getAttribute("class");
        String[] classes = null;
        String theClass = null;
        try {
            if (cls != null) {
                classes = cls.asStrings();
                if (classes.length > 0) {
                    theClass = classes[classes.length - 1];
                }
            }
        } catch (Exception e) {
        }


        if (value == null) {
            if ((row + 1) <= numRealRows && (col + 1) <= numRealCols) {
                SimDat.eval(rDataName + "[" + (row + 1) + "," + (col + 1) + "]<-NA",curEnv);
            }
        } else if (currentValue.isNull()) {
            if (!isDouble) {
                if (value.toString().equals("NA")) {
                    SimDat.eval(rDataName + "[" + (row + 1) + "," + (col + 1) + "]<-NA",curEnv);
                } else if (value.toString().toLowerCase().equals("true")) {
                    SimDat.eval(rDataName + "[" + (row + 1) + "," + (col + 1) + "]<-TRUE",curEnv);
                } else if (value.toString().toLowerCase().equals("false")) {
                    SimDat.eval(rDataName + "[" + (row + 1) + "," + (col + 1) + "]<-FALSE",curEnv);
                } else {
                    SimDat.eval(rDataName + "[" + (row + 1) + "," + (col + 1) + "]<-'" + value.toString() + "'",curEnv);
                }
            } else {
                SimDat.eval(rDataName + "[" + (row + 1) + "," + (col + 1) + "]<-" + valueString,curEnv);

            }
        } else if (value.toString().equals("NA")) {
            SimDat.eval(rDataName + "[" + (row + 1) + "," + (col + 1) + "]<-NA",curEnv);
        } else if (currentValue.isString()) {
            SimDat.eval(rDataName + "[" + (row + 1) + "," + (col + 1) + "]<-'" + value.toString() + "'",curEnv);
        } else if (currentValue.isFactor()) {
            boolean isNewLevel = ((REXPLogical) SimDat.eval("'" + value.toString() + "' %in% "
                    + "levels(" + rDataName + "[," + (col + 1) + "])",curEnv)).isFALSE()[0];

            if (isNewLevel) {
                String addLevel = "levels(" + rDataName + "[," + (col + 1) + "])<-c("
                        + "levels(" + rDataName + "[," + (col + 1) + "]),'" + value.toString() + "')";
                SimDat.eval(addLevel,curEnv);
            }
            SimDat.eval(rDataName + "[" + (row + 1) + "," + (col + 1) + "]<-'" + value.toString() + "'",curEnv);
        } else if (currentValue.isLogical()) {
            if (valueString.equals("1") || valueString.toLowerCase().equals("true")
                    || valueString.toLowerCase().equals("t")) {
                SimDat.eval(rDataName + "[" + (row + 1) + "," + (col + 1) + "]<-TRUE",curEnv);
            } else if (valueString.equals("0") || valueString.toLowerCase().equals("false")
                    || valueString.toLowerCase().equals("f")) {
                SimDat.eval(rDataName + "[" + (row + 1) + "," + (col + 1) + "]<-FALSE",curEnv);
            } else {
                SimDat.eval(rDataName + "[" + (row + 1) + "," + (col + 1) + "]<-'" + valueString + "'",curEnv);
                this.fireTableDataChanged();
            }
        } else if (theClass == null && currentValue.isInteger()) {
            if (!isInteger) {
                if (!isDouble) {
                    SimDat.eval(rDataName + "[," + (col + 1) + "]<-as.character(" + rDataName + "[," + (col + 1) + "])",curEnv);
                    SimDat.eval(rDataName + "[" + (row + 1) + "," + (col + 1) + "]<-'" + value.toString() + "'",curEnv);
                } else {
                    SimDat.eval(rDataName + "[" + (row + 1) + "," + (col + 1) + "]<-" + valueString,curEnv);
                }
                this.fireTableDataChanged();
            } else {
                SimDat.eval(rDataName + "[" + (row + 1) + "," + (col + 1) + "]<-" + valueString + "L",curEnv);
            }
        } else if (theClass == null && currentValue.isNumeric()) {
            if (!isDouble) {
                SimDat.eval(rDataName + "[," + (col + 1) + "]<-as.character(" + rDataName + "[," + (col + 1) + "])",curEnv);
                SimDat.eval(rDataName + "[" + (row + 1) + "," + (col + 1) + "]<-'" + value.toString() + "'",curEnv);
            } else {
                SimDat.eval(rDataName + "[" + (row + 1) + "," + (col + 1) + "]<-" + valueString,curEnv);
            }
            this.fireTableDataChanged();
        } else if (theClass != null) {
            SimDat.eval(rDataName + "[" + (row + 1) + "," + (col + 1) + "]<-as." + theClass + "('" + value.toString() + "')",curEnv);
        }
        this.fireTableCellUpdated(row, col);
        if ((row + 1) > numRealRows) {
            SimDat.eval("rownames(" + rDataName + ")<-make.unique(rownames(" + rDataName + "))",curEnv);
            this.fireTableRowsInserted(numRealRows, row);
            this.fireTableRowsUpdated(numRealRows, row);
            rowNamesModel.refresh();
        }
        if ((col + 1) > numRealCols) {
            this.fireTableDataChanged();
            refresh();
        }

        try {
            data = SimDat.eval(tempDataName + "<-" + rDataName,curEnv).asList();
        } catch (REXPMismatchException e) {
            new ErrorMsg(e);
        }
    }

    /**
     * Notifies components about changes in the model
     */
    public boolean refresh() {
        boolean changed = false;
        REXP exist = SimDat.eval("exists('" + rDataName + "')",curEnv);
        if (exist != null && ((REXPLogical) exist).isTRUE()[0]) {
            REXP ident = SimDat.eval("identical(" + rDataName + "," + tempDataName + ")",curEnv);
            if (ident != null && ((REXPLogical) ident).isFALSE()[0]) {
                REXP strSame = SimDat.eval("all(dim(" + rDataName + ")==dim(" + tempDataName + ")) && "
                        + "identical(colnames(" + rDataName + "),colnames(" + tempDataName + "))",curEnv);
                try {
                    data = SimDat.eval(tempDataName + "<-" + rDataName,curEnv).asList();
                } catch (REXPMismatchException e) {
                    new ErrorMsg(e);
                }
                if (strSame != null && !((REXPLogical) strSame).isTRUE()[0]) {
                    this.fireTableStructureChanged();
                }
                if (strSame != null) {
                    this.fireTableDataChanged();
                }

                changed = true;
            }
        }
        return changed;
    }

    public String getColumnName(int col) {
        if (col < getRealColumnCount()) {
            REXP colName = SimDat.eval("colnames(" + rDataName + ")[" + (col + 1) + "]",curEnv);
            if (colName.isString()) {
                try {
                    return colName.asString();
                } catch (REXPMismatchException e) {
                    return "?";
                }
            } else {
                return "?";
            }
        } else {
            return "";
        }
    }

    public boolean isCellEditable(int rowIndex, int columnIndex) {
        if (columnIndex <= getRealColumnCount()) {
            return true;
        } else {
            return false;
        }
    }

    /**
     * 		Deletes the cached data frame from the gui environment
     */
    public void removeCachedData() {


        boolean envDefined = SimDat.envDefined(curEnv);

        if (!envDefined) {
            //SimDat.GlobalEval(curEnv + "<-new.env(parent=emptyenv())");
            SimDat.GlobalEval(curEnv + "<-new.env()");
        }
        boolean tempStillExists = false;
        //REXP tmp = SimDat.eval("exists('" + tempDataName + "',where=" + guiEnv + ",inherits=FALSE)");
        REXP tmp = SimDat.eval("exists('" + tempDataName + "')",curEnv);
        if (tmp instanceof REXPLogical) {
            tempStillExists = ((REXPLogical) tmp).isTRUE()[0];
        }
        if (tempStillExists) {
            //SimDat.eval("rm(" + tempDataName + ",envir=" + guiEnv + ")");
            SimDat.eval("rm(" + tempDataName + ")",curEnv);
        }
    }

    protected void finalize() throws Throwable {
        removeCachedData();
        super.finalize();
    }

    class RowNamesModel extends RowNamesListModel {

        private String[] rowNames = null;
        private int maxChar = -1;

        public int getSize() {
            return getRowCount();
        }

        public Object getElementAt(int index) {
            if (rowNames == null) {
                refresh();
            }
            if (index < getRealRowCount()) {
                if (rowNames.length > index) {
                    return rowNames[index];
                } else {
                    return "?";
                }
            } else {
                return new Integer(index + 1).toString();
            }
        }

        public void initHeaders(int n) {
        }

        public int getMaxNumChar() {
            if (maxChar < 0) {
                refresh();
            }
            return maxChar;
        }

        public void refresh() {
            if (rDataName == null) {
                rowNames = new String[]{};
                super.refresh();
                return;
            }
            REXP exist = SimDat.eval("exists('" + rDataName + "')",curEnv);
            if (exist == null || !((REXPLogical) exist).isTRUE()[0]) {
                rowNames = new String[]{};
                super.refresh();
                return;
            }
            try {
                rowNames = SimDat.eval("rownames(" + rDataName + ")",curEnv).asStrings();
            } catch (REXPMismatchException e) {
                new ErrorMsg(e);
            }
            int max = 0;
            for (int i = 0; i < rowNames.length; i++) {
                max = Math.max(max, rowNames[i].length());
            }
            maxChar = max;
            super.refresh();
        }

        public void setElementAt(int index, Object value) {
            if (index >= getRealRowCount()) {
                return;
            }
            String valueString = null;
            boolean isDouble = false;
            boolean isInteger = false;
            if (value == null) {
                return;
            }
            valueString = value.toString().trim();
            isDouble = true;
            try {
                Double.parseDouble(valueString);
            } catch (Exception e) {
                isDouble = false;
            }
            isInteger = true;
            try {
                Integer.parseInt(valueString);
            } catch (Exception ex) {
                isInteger = false;
            }

            if (isInteger || isDouble) {
                SimDat.eval("rownames(" + rDataName + ")[" + (index + 1) + "] <- " + valueString,curEnv);
            } else {
                SimDat.eval("rownames(" + rDataName + ")[" + (index + 1) + "] <- '" + valueString + "'",curEnv);
            }
            refresh();
        }
    }

    public RowNamesListModel getRowNamesModel() {
        return rowNamesModel;
    }

    public void setRowNamesModel(RowNamesModel model) {
        rowNamesModel = model;
    }

    public class NAHolder {

        public String toString() {
            return "NA";
        }
    }

    /**
     * 		Implements nice printing of NAs, as well as left alignment
     * 		for strings and right alignment for numbers.
     *
     * @author ifellows
     *
     */
    public class RCellRenderer extends ExCellRenderer {

        public Component getTableCellRendererComponent(JTable table,
                Object value, boolean selected, boolean focused,
                int row, int column) {
            super.getTableCellRendererComponent(table, value,
                    selected, focused, row, column);

            if (row < getRealRowCount() || column < getRealColumnCount()) {
                if (value instanceof NAHolder) {
                    setHorizontalAlignment(RIGHT);
                    setVerticalAlignment(BOTTOM);
                    Font f = new Font("Dialog", Font.PLAIN, 6);
                    setFont(f);
                } else if (value instanceof String) {
                    setHorizontalAlignment(LEFT);
                    setVerticalAlignment(CENTER);
                } else {
                    setHorizontalAlignment(RIGHT);
                    setVerticalAlignment(CENTER);
                }
            }

            return this;
        }
    }
}
