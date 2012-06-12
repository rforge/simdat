/* TODO:
variable renaming
adding variable
 */
package simdat.toolkit;

import simdat.SimDat;
import simdat.toolkit.*;
import simdat.data.CovariateEditorModel;
//import simdat.data.RdfRowEditorModel;

//import simdat.main.SimDatMainTab;
import org.rosuda.deducer.data.ExTable;
import org.rosuda.deducer.data.ExScrollableTable;

import java.awt.BorderLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;

import javax.swing.DefaultCellEditor;
import javax.swing.JComboBox;
import javax.swing.JFrame;
import javax.swing.JMenuBar;
import javax.swing.JOptionPane;
import javax.swing.JTable;
import javax.swing.JPanel;

import org.rosuda.JGR.RController;
import org.rosuda.JGR.editor.Editor;
import org.rosuda.JGR.toolkit.AboutDialog;
import org.rosuda.JGR.util.ErrorMsg;
import org.rosuda.REngine.REXPLogical;
//import org.rosuda.deducer.Deducer;
//import org.rosuda.deducer.data.RDataFrameVariableModel.VariableNumberListModel;
//import org.rosuda.deducer.data.RDataFrameVariableModel;
//import org.rosuda.deducer.toolkit.LoadData;
//import org.rosuda.deducer.toolkit.SaveData;
import simdat.toolkit.FactorDialog;
import org.rosuda.ibase.Common;
import org.rosuda.ibase.toolkit.EzMenuSwing;

public class CovariateEditor extends JPanel {

    protected String modelName;
    protected String guiEnv;
    protected ExScrollableTable variableScrollPane;
    protected ExTable ex;
    protected DistributionList dlist;

    public CovariateEditor(String modelName,String guiEnv) {
        //super();
        init(modelName,guiEnv);
    }

    // 0 = name
    // 1 = model
    // 2 = mean
    // 3 = sd

    private void init(String modelName, String guiEnv) {
        this.modelName = modelName;
        this.guiEnv = guiEnv;

        // variable scale
        dlist = new DistributionList();
        //scomboBox.addItem("Nominal");
        //scomboBox.addItem("Ordinal");


        CovariateEditorModel varModel = new CovariateEditorModel(modelName,guiEnv);
        ex = new ExTable();
        ex.setModel(varModel);
        ex.getColumnModel().getColumn(1).setCellEditor(new DefaultCellEditor(dlist));
        ex.getColumnModel().getColumn(0).setPreferredWidth(110);
        ex.getColumnModel().getColumn(1).setPreferredWidth(110);
        ex.getColumnModel().getColumn(2).setPreferredWidth(70);
        ex.getColumnModel().getColumn(3).setPreferredWidth(70);
        ex.getColumnModel().getColumn(4).setPreferredWidth(70);
        ex.getColumnModel().getColumn(5).setPreferredWidth(70);
        ex.setColumnSelectionAllowed(true);
        ex.setRowSelectionAllowed(true);
        ex.getTableHeader().removeMouseListener(ex.getColumnListener());

        variableScrollPane = new ExScrollableTable(ex);
        variableScrollPane.setRowNamesModel(varModel.new CovariateNumberListModel());
        //variableScrollPane.setRowNamesModel(((CovariateEditorModel) variableScrollPane.getExTable().getModel()).getRowNamesModel());
        variableScrollPane.displayContextualMenu(false);
        this.setLayout(new BorderLayout());
        this.add(variableScrollPane);
    }

    public void setData(String model) {
       setData(model,guiEnv);
        //variableScrollPane.setRowNamesModel(((CovariateEditorModel) variableScrollPane.getExTable().getModel()).getRowNamesModel());
    }

    public void setData(String model, String curEnv) {
        modelName = model;
        guiEnv = curEnv;
        CovariateEditorModel varModel = new CovariateEditorModel(modelName,guiEnv);
        ex.setModel(varModel);
        ex.getColumnModel().getColumn(1).setCellEditor(new DefaultCellEditor(dlist));

        ex.getColumnModel().getColumn(0).setPreferredWidth(110);
        ex.getColumnModel().getColumn(1).setPreferredWidth(110);
        ex.getColumnModel().getColumn(2).setPreferredWidth(70);
        //ex.getColumnModel().getColumn(3).setPreferredWidth(250);
        ex.getColumnModel().getColumn(3).setPreferredWidth(70);
        ex.getColumnModel().getColumn(4).setPreferredWidth(70);
        ex.getColumnModel().getColumn(5).setPreferredWidth(70);

        variableScrollPane.setRowNamesModel(varModel.new CovariateNumberListModel());
        //variableScrollPane.setRowNamesModel(((RdfRowEditorModel) variableScrollPane.getExTable().getModel()).getRowNamesModel());
    }

    public void refresh() {
        int colStart = -1;
        int colEnd = -1;
        int rowStart = -1;
        int rowEnd = -1;
        int[] cols = ex.getSelectedColumns();
        if (cols.length > 0) {
            colStart = cols[0];
            colEnd = cols[cols.length - 1];
        }
        int[] rows = ex.getSelectedRows();
        if (rows.length > 0) {
            rowStart = rows[0];
            rowEnd = rows[rows.length - 1];
        }
        ((CovariateEditorModel) variableScrollPane.getExTable().getModel()).refresh();
        variableScrollPane.getRowNamesModel().refresh();
        variableScrollPane.autoAdjustRowWidth();

        if (colStart != -1 && colEnd != -1 && rowStart != -1 && rowEnd != -1) {
            ex.changeSelection(rowStart, colStart, false, false);
            ex.changeSelection(rowEnd, colEnd, false, true);
        }
    }

    public void cleanUp() {
    }
}
