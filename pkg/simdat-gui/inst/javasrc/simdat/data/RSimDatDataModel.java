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
//import org.rosuda.deducer.Deducer;

/**
 * Data Frame model
 * 
 * @author ifellows
 *
 */
public class RSimDatDataModel extends ExDefaultTableModel {

    private static String guiEnv = SimDat.guiEnv;
    private static REXPReference formatDate;
    private String rModelName = null;
    private String tempModelName = null;
    private RList data = null;
    RowNamesModel rowNamesModel = new RowNamesModel();
    public static final int numExtensionRows = 50;
    public static final int numExtensionColumns = 10;

    public RSimDatDataModel() {
    }

    public RSimDatDataModel(String name) {
        setModelName(name);
    }

    public String getModelName() {
        return rModelName;
    }

    public void setModelName(String name) {

        //boolean envDefined = ((REXPLogical)SimDat.eval("'"+guiEnv+"' %in% .getOtherObjects()")).isTRUE()[0];
        //boolean envDefined = ((REXPLogical)SimDat.eval("exists('"+guiEnv+"')")).isTRUE()[0];

        //if(!envDefined){
        //	SimDat.GlobalEval(guiEnv+"<-new.env(parent=emptyenv())");
        //}
        if (tempModelName != null) {
            removeCachedData();
        }
        rModelName = name;
        if (rModelName != null) {
            //tempModelName = SimDat.getUniqueName(rModelName + Math.random(),guiEnv);
            tempModelName = SimDat.getUniqueName(rModelName + Math.random());
            try {
                //data = SimDat.eval(guiEnv+"$"+tempModelName+"<- getData("+rModelName+")").asList(); // transfer data to data
                data = SimDat.eval(tempModelName + "<- getData(" + rModelName + ")").asList(); // transfer data to data
            } catch (REXPMismatchException e) {
                new ErrorMsg(e);
            }
        }
        this.fireTableStructureChanged();
        this.fireTableDataChanged();
    }

    public int getColumnCount() {
        if (rModelName != null) {
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
        if (rModelName != null) {

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
        if (rModelName != null) {
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
        if (rModelName != null) {
            try {
                return ((REXPVector) data.at(0)).length() + numExtensionRows;
            } catch (Exception e) {
                return 0;
            }
        } else {
            return 0;
        }
    }

    // TODO: delete variable from model (dangerous; breaks everything!!!)
    public void removeColumn(int colNumber) {
        if (colNumber < getRealColumnCount()) {
            SimDat.eval(rModelName + "<-" + rModelName + "[,-" + (colNumber + 1) + "]");
            refresh();
        }
    }

    public void removeRow(int row) {
        if ((row + 1) <= getRealRowCount()) {
            SimDat.eval(rModelName + "<- removeRow(" + rModelName + ", idx = " + (row + 1) + ")");
            refresh();
        }
    }

    public void insertNewColumn(int col) {
        if (col > getRealColumnCount() + 1) {
            return;
        }
        if (col < 1) {
            SimDat.eval("addVariable(" + rModelName + ",new('IntervalVariable',.Data=NA,idx=1)");
        } else if (col >= getRealColumnCount()) {
            SimDat.eval("addVariable(" + rModelName + ",new('IntervalVariable',.Data=NA)");
        } //SimDat.eval(rModelName+"<-data.frame("+rModelName+",V=as.integer(NA))");
        else {
            SimDat.eval("addVariable(" + rModelName + ",new('IntervalVariable',.Data=NA),idx=" + col + 1 + ")");
        }
        // SimDat.eval(rModelName+"<-data.frame("+rModelName+"[,1:"+col+",drop=FALSE],V=as.integer(NA),"+
        //	rModelName+"[,"+(col+1)+":"+getRealColumnCount()+",drop=FALSE])");
        refresh();
    }

    public void insertNewRow(int row) {
        //int rowCount = getRealRowCount();
        //setValueAt("NA", Math.max(rowCount, row), 0);
        //SimDat.eval("attr("+rModelName+",'row.names')["+(Math.max(rowCount,row)+1)+"]<-'New'");
        SimDat.eval(rModelName + "<- insertRow(" + rModelName + ",idx = " + (row + 1) + ")");
        //            + "[" + (rowCount + 1) + ",]," + rModelName + "[" + (row + 1) + ":" + rowCount + ",,drop=FALSE])");
        //} else if (row < rowCount) {
        //    SimDat.eval(rModelName + "<-rbind(" + rModelName + "[1:" + row + ",,drop=FALSE]," + rModelName
        //            + "[" + (rowCount + 1) + ",]," + rModelName + "[" + (row + 1) + ":" + rowCount + ",,drop=FALSE])");
        //}
        //SimDat.eval("rownames("+rModelName+")<-make.unique(rownames("+rModelName+"))");

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
                    REXP val = SimDat.eval("format(getData(" + rModelName + ")[" + (row + 1) + "," + (col + 1) + "])");
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
        REXP currentValue = SimDat.eval("getData(" + rModelName + ")[" + (row + 1) + "," + (col + 1) + "]");
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
                SimDat.eval("setValueAt(" + rModelName + ",NA,data_row=" + (row + 1) + ",data_column=" + (col + 1) + ")");
            }
        } else if (currentValue.isNull()) {
            if (!isDouble) {
                if (value.toString().equals("NA")) {
                    SimDat.eval("setValueAt(" + rModelName + ",NA,data_row=" + (row + 1) + ",data_column=" + (col + 1) + ")");
                } //SimDat.eval(rModelName+"["+(row+1)+","+(col+1)+"]<-NA");
                else if (value.toString().toLowerCase().equals("true")) {
                    SimDat.eval("setValueAt(" + rModelName + ",TRUE,data_row=" + (row + 1) + ",data_column=" + (col + 1) + ")");
                } else if (value.toString().toLowerCase().equals("false")) {
                    SimDat.eval("setValueAt(" + rModelName + ",FALSE,data_row=" + (row + 1) + ",data_column=" + (col + 1) + ")");
                } else {
                    SimDat.eval("setValueAt(" + rModelName + "," + value.toString() + ",data_row=" + (row + 1) + ",data_column=" + (col + 1) + ")");
                }
            } else {
                SimDat.eval("setValueAt(" + rModelName + "," + valueString + ",data_row=" + (row + 1) + ",data_column=" + (col + 1) + ")");
            }
        } else if (value.toString().equals("NA")) {
            SimDat.eval("setValueAt(" + rModelName + ",NA,data_row=" + (row + 1) + ",data_column=" + (col + 1) + ")");
        } else if (currentValue.isString()) {
            SimDat.eval("setValueAt(" + rModelName + "," + value.toString() + ",data_row=" + (row + 1) + ",data_column=" + (col + 1) + ")");
        } else if (currentValue.isFactor()) {
            SimDat.eval("setValueAt(" + rModelName + ",'" + value.toString() + "',data_row=" + (row + 1) + ",data_column=" + (col + 1) + ")");
            /*
            boolean isNewLevel=((REXPLogical)SimDat.eval("'"+value.toString()+"' %in% " +
            "levels(" +rModelName+"[,"+(col+1)+"])")).isFALSE()[0];

            if(isNewLevel){
            String addLevel = "levels(" +rModelName+"[,"+(col+1)+"])<-c("+
            "levels(" +rModelName+"[,"+(col+1)+"]),'"+value.toString()+"')";
            Deducer.eval(addLevel);
            }
            Deducer.eval(rModelName+"["+(row+1)+","+(col+1)+"]<-'"+value.toString()+"'");
             *

            } /*else if( currentValue.isLogical()){
            if(valueString.equals("1") || valueString.toLowerCase().equals("true")
            || valueString.toLowerCase().equals("t"))
            Deducer.eval(rModelName+"["+(row+1)+","+(col+1)+"]<-TRUE");
            else if(valueString.equals("0") || valueString.toLowerCase().equals("false")
            || valueString.toLowerCase().equals("f"))
            Deducer.eval(rModelName+"["+(row+1)+","+(col+1)+"]<-FALSE");
            else{
            Deducer.eval(rModelName+"["+(row+1)+","+(col+1)+"]<-'"+valueString+"'");
            this.fireTableDataChanged();
            }
             */
        } else if (theClass == null && currentValue.isInteger()) {
            if (!isInteger) {
                if (!isDouble) {
                    //SimDat.eval("setValueAt(" + rModelName + ", as.integer(" + value.toString() + "),data_row=" + (row+1) + ",data_column = " + (col+1) + ")");
                    //SimDat.eval(rModelName+"["+(row+1)+","+(col+1)+"]<-'"+value.toString()+"'");
                } else {
                    SimDat.eval("setValueAt(" + rModelName + ", as.integer(" + valueString + "),data_row=" + (row + 1) + ",data_column = " + (col + 1) + ")");
                    //SimDat.eval(rModelName+"["+(row+1)+","+(col+1)+"]<-"+valueString);
                }
                this.fireTableDataChanged();
            } else {
                SimDat.eval("setValueAt(" + rModelName + "," + valueString + "L,data_row=" + (row + 1) + ",data_column = " + (col + 1) + ")");
            }
        } else if (theClass == null && currentValue.isNumeric()) {
            if (!isDouble) {
                //SimDat.eval(rModelName+"[,"+(col+1)+"]<-as.character("+rModelName+"[,"+(col+1)+"])");
                //SimDat.eval(rModelName+"["+(row+1)+","+(col+1)+"]<-'"+value.toString()+"'");
                //SimDat.eval("setValueAt(" + rModelName + "," + value.toString() + ",data_row=" + (row+1) + ",data_column = " + (col+1) + ")");
            } else {
                //SimDat.eval(rModelName+"["+(row+1)+","+(col+1)+"]<-"+valueString);
                SimDat.eval("setValueAt(" + rModelName + "," + value.toString() + ",data_row=" + (row + 1) + ",data_column = " + (col + 1) + ")");
            }
            this.fireTableDataChanged();
        } else if (theClass != null) {
            SimDat.eval(rModelName + "[" + (row + 1) + "," + (col + 1) + "]<-as." + theClass + "('" + value.toString() + "')");
        }
        this.fireTableCellUpdated(row, col);
        /*
         */
        if ((row + 1) > numRealRows) {
            //SimDat.eval("rownames("+rModelName+")<-make.unique(rownames("+rModelName+"))");
            this.fireTableRowsInserted(numRealRows, row);
            this.fireTableRowsUpdated(numRealRows, row);
            rowNamesModel.refresh();
        }
        if ((col + 1) > numRealCols) {
            this.fireTableDataChanged();
            refresh();
        }

        try {
            //data = SimDat.eval(guiEnv+"$"+tempModelName+"<-"+rModelName).asList();
            data = SimDat.eval(tempModelName + "<- getData(" + rModelName + ")").asList();
        } catch (REXPMismatchException e) {
            new ErrorMsg(e);
        }
    }

    /**
     * Notifies components about changes in the model
     */
    public boolean refresh() {
        boolean changed = false;
        REXP exist = SimDat.eval("exists('" + rModelName + "')");
        if (exist != null && ((REXPLogical) exist).isTRUE()[0]) {
            //REXP ident = SimDat.eval("identical("+rModelName+","+guiEnv+"$"+tempModelName+")");
            REXP ident = SimDat.eval("identical(" + rModelName + "," + tempModelName + ")");
            if (ident != null && ((REXPLogical) ident).isFALSE()[0]) {
                //REXP strSame = SimDat.eval("all(dim(getData("+rModelName+"))==dim(getData("+guiEnv+"$"+tempModelName+"))) && " +
                //    "identical(variableNames("+rModelName+"),variableNames("+guiEnv+"$"+tempModelName+"))");
                REXP strSame = SimDat.eval("all(dim(getData(" + rModelName + "))==dim(" + tempModelName + ")) && "
                        + "identical(variableNames(" + rModelName + "),colnames(" + tempModelName + "))");
                try {
                    data = SimDat.eval(tempModelName + "<- getData(" + rModelName + ")").asList();
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
            REXP colName = SimDat.eval("colnames(getData(" + rModelName + "))[" + (col + 1) + "]");
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
        //boolean envDefined = ((REXPLogical)Deducer.eval("'"+guiEnv+"' %in% .getOtherObjects()")).isTRUE()[0];
        boolean envDefined = ((REXPLogical) SimDat.eval("exists('" + guiEnv + "')")).isTRUE()[0];

        if (!envDefined) {
            SimDat.eval(guiEnv + "<-new.env(parent=emptyenv())");
        }
        boolean tempStillExists = false;
        //REXP tmp = SimDat.eval("exists('"+tempModelName+"',where="+guiEnv+",inherits=FALSE)");
        REXP tmp = SimDat.eval("exists('" + tempModelName + "',inherits=FALSE)");
        if (tmp instanceof REXPLogical) {
            tempStillExists = ((REXPLogical) tmp).isTRUE()[0];
        }
        if (tempStillExists) {
            SimDat.eval("rm(" + tempModelName + ")");
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
            if (rModelName == null) {
                rowNames = new String[]{};
                super.refresh();
                return;
            }
            REXP exist = SimDat.eval("exists('" + rModelName + "')");
            if (exist == null || !((REXPLogical) exist).isTRUE()[0]) {
                rowNames = new String[]{};
                super.refresh();
                return;
            }
            try {
                rowNames = SimDat.eval("rownames(getData(" + rModelName + "))").asStrings();
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
                SimDat.eval("rownames(" + rModelName + ")[" + (index + 1) + "] <- " + valueString);
            } else {
                SimDat.eval("rownames(" + rModelName + ")[" + (index + 1) + "] <- '" + valueString + "'");
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
