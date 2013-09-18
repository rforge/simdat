/* TODO:
variable renaming
adding variable
 */
package simdat.toolkit;

import simdat.SimDat;
import simdat.toolkit.*;
import simdat.data.ModelEditorModel;

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

public class ModelEditor extends JPanel {

    protected String modelName;
    protected String guiEnv;
    protected ExScrollableTable variableScrollPane;
    protected ExTable ex;
    protected JComboBox mcomboBox;

    public ModelEditor(String modelName, String guiEnv) {
        //super();
        init(modelName, guiEnv);
    }

    private void init(String modelName, String guiEnv) {
        this.modelName = modelName;
        this.guiEnv = guiEnv;

        // variable scale
        mcomboBox = new JComboBox();
        //scomboBox.addItem("Nominal");
        //scomboBox.addItem("Ordinal");
        mcomboBox.addItem("UniformModel");
        mcomboBox.addItem("NormalModel");
        mcomboBox.addItem("GamlssModel");


        ModelEditorModel varModel = new ModelEditorModel(modelName, guiEnv);
        ex = new ExTable();
        ex.setModel(varModel);
        ex.getColumnModel().getColumn(1).setCellEditor(new DefaultCellEditor(mcomboBox));
        ex.getColumnModel().getColumn(0).setPreferredWidth(110);
        ex.getColumnModel().getColumn(1).setPreferredWidth(110);
        ex.getColumnModel().getColumn(2).setPreferredWidth(70);
        //ex.getColumnModel().getColumn(3).setPreferredWidth(250);
        ex.setColumnSelectionAllowed(false);
        ex.setRowSelectionAllowed(false);
        ex.getTableHeader().removeMouseListener(ex.getColumnListener());


        ex.addMouseListener(new MouseAdapter() {

            public void mouseClicked(MouseEvent e) {
                ExTable extab = (ExTable) e.getSource();
                if (extab.getSelectedColumn() == 2) {
                    int row = extab.getSelectedRow();
                    String varName = (String) extab.getModel().getValueAt(row, 0);
                    String modType = (String) extab.getModel().getValueAt(row, 1);
                    String modName = ModelEditor.this.modelName;
                    if (modType == "") {
                    } else if (modType == "UniformModel") {
                    } else if (modType == "NormalModel") {
                    } else if (modType == "GamlssModel") {
                        JOptionPane.showMessageDialog(null, "This is not implemented yet");
                    }


                }
            }
        });

        variableScrollPane = new ExScrollableTable(ex);
        variableScrollPane.setRowNamesModel(varModel.new ModelNumberListModel());
        variableScrollPane.displayContextualMenu(false);
        this.setLayout(new BorderLayout());
        this.add(variableScrollPane);
    }

    public void setData(String model) {
        modelName = model;
        ModelEditorModel varModel = new ModelEditorModel(modelName, guiEnv);
        ex.setModel(varModel);
        ex.getColumnModel().getColumn(1).setCellEditor(new DefaultCellEditor(mcomboBox));

        ex.getColumnModel().getColumn(0).setPreferredWidth(110);
        ex.getColumnModel().getColumn(1).setPreferredWidth(110);
        ex.getColumnModel().getColumn(2).setPreferredWidth(70);


        variableScrollPane.setRowNamesModel(varModel.new ModelNumberListModel());
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
        ((ModelEditorModel) variableScrollPane.getExTable().getModel()).refresh();
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
