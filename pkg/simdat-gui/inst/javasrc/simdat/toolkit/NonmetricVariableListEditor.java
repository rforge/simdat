/* TODO:
variable renaming
adding variable
 */
package simdat.toolkit;

import simdat.SimDat;
import simdat.toolkit.*;
import simdat.data.NonmetricVariableListEditorModel;
import java.awt.Component;
import javax.swing.SwingUtilities;
import java.awt.Window;
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

public class NonmetricVariableListEditor extends JPanel {

    protected String modelName;
    protected String guiEnv;
    protected ExScrollableTable variableScrollPane;
    protected ExTable ex;
    protected JComboBox scomboBox;
    protected JComboBox tcomboBox;
    private JFrame parentFrame;
    protected boolean defaultNominal;
    protected boolean cType;
    protected boolean defaultFixed;
    protected boolean cScale;
    protected int mLength;

    public NonmetricVariableListEditor(String modelName, String guiEnv, boolean defaultNominal, boolean changeScale, boolean defaultFixed, boolean changeType, int maxLength) {
        //super();
        this.defaultFixed = defaultFixed;
        this.defaultNominal = defaultNominal;
        this.cScale = changeScale;
        this.cType = changeType;
        this.mLength = maxLength;
        init(modelName, guiEnv);
    }
    // 0 = name
    // 1 = scale
    // 2 = random
    // 3 = min
    // 4 = max
    // 5 = digits

    private void init(String modelName, String guiEnv) {
        this.modelName = modelName;
        this.guiEnv = guiEnv;

        // variable scale
        scomboBox = new JComboBox();
        scomboBox.addItem("Nominal");
        scomboBox.addItem("Ordinal");
        //scomboBox.addItem("Interval");
        //scomboBox.addItem("Ratio");

        // variable type
        tcomboBox = new JComboBox();
        tcomboBox.addItem("Fixed");
        tcomboBox.addItem("Random");

        NonmetricVariableListEditorModel varModel = new NonmetricVariableListEditorModel(modelName, guiEnv, defaultNominal, cScale, defaultFixed, cType, mLength);
        ex = new ExTable();
        ex.setModel(varModel);
        ex.getColumnModel().getColumn(1).setCellEditor(new DefaultCellEditor(scomboBox));
        ex.getColumnModel().getColumn(2).setCellEditor(new DefaultCellEditor(tcomboBox));
        ex.getColumnModel().getColumn(0).setPreferredWidth(110);
        ex.getColumnModel().getColumn(1).setPreferredWidth(70);
        ex.getColumnModel().getColumn(2).setPreferredWidth(70);
        ex.getColumnModel().getColumn(3).setPreferredWidth(250);
        //ex.getColumnModel().getColumn(3).setPreferredWidth(70);
        //ex.getColumnModel().getColumn(4).setPreferredWidth(70);
        //ex.getColumnModel().getColumn(5).setPreferredWidth(70);
        ex.setColumnSelectionAllowed(true);
        ex.setRowSelectionAllowed(true);
        ex.getTableHeader().removeMouseListener(ex.getColumnListener());
        ex.addMouseListener(new MouseAdapter() {

            private JFrame getParentFrame(Component obj) {
                if (parentFrame == null) {
                    Component parent = obj.getParent();
                    while (!(parent instanceof JFrame) && parent != null) {
                        parent = parent.getParent();
                    }
                    parentFrame = (JFrame) parent;
                }
                return parentFrame;
            }

            public void mouseClicked(MouseEvent e) {
                ExTable extab = (ExTable) e.getSource();
                if (extab.getSelectedColumn() == 3) {
                    int row = extab.getSelectedRow();
                    String varName = (String) extab.getModel().getValueAt(row, 0);
                    EditFactor(varName);
                }
            }
        });

        variableScrollPane = new ExScrollableTable(ex);
        variableScrollPane.setRowNamesModel(varModel.new VariableNumberListModel());
        variableScrollPane.displayContextualMenu(false);
        this.setLayout(new BorderLayout());
        this.add(variableScrollPane);
    }

    public void setData(String model) {
        modelName = model;
        NonmetricVariableListEditorModel varModel = new NonmetricVariableListEditorModel(modelName, guiEnv, defaultNominal, cScale, defaultFixed, cType, mLength);
        ex.setModel(varModel);
        ex.getColumnModel().getColumn(1).setCellEditor(new DefaultCellEditor(scomboBox));
        ex.getColumnModel().getColumn(2).setCellEditor(new DefaultCellEditor(tcomboBox));

        ex.getColumnModel().getColumn(0).setPreferredWidth(110);
        ex.getColumnModel().getColumn(1).setPreferredWidth(70);
        ex.getColumnModel().getColumn(2).setPreferredWidth(70);
        ex.getColumnModel().getColumn(3).setPreferredWidth(250);
        //ex.getColumnModel().getColumn(3).setPreferredWidth(70);
        //ex.getColumnModel().getColumn(4).setPreferredWidth(70);
        //ex.getColumnModel().getColumn(5).setPreferredWidth(70);

        variableScrollPane.setRowNamesModel(varModel.new VariableNumberListModel());
    }

    private void EditFactor(String varName) {

        String modName = NonmetricVariableListEditor.this.modelName;
        String guiEnv = NonmetricVariableListEditor.this.guiEnv;
        REXPLogical tmp;
        Window tFrame = SwingUtilities.windowForComponent(this);
        try {
            //JFrame tFrame = new JFrame();
            //JFrame tFrame = getParentFrame(extab);
            tmp = (REXPLogical) SimDat.eval("is.factor(getData(" + modName + ")$" + varName + ")", guiEnv);
            if (tmp != null && tmp.isTRUE()[0]) {
                FactorDialog fact = new FactorDialog(tFrame, modName, varName, guiEnv);
                fact.setLocationRelativeTo(ex);
                fact.setTitle("Factor Editor: " + varName);
                fact.setVisible(true);
                //fact.requestFocus();
                //fact.requestFocusInWindow();
            }
        } catch (Exception exc) {
        }

        this.refresh();

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
        ((NonmetricVariableListEditorModel) variableScrollPane.getExTable().getModel()).refresh();
        variableScrollPane.getRowNamesModel().refresh();
        variableScrollPane.autoAdjustRowWidth();

        if (colStart != -1 && colEnd != -1 && rowStart != -1 && rowEnd != -1) {
            ex.changeSelection(rowStart, colStart, false, false);
            ex.changeSelection(rowEnd, colEnd, false, true);
        }
    }
    
    public int nValues()
    {
        return ((NonmetricVariableListEditorModel) ex.getModel()).getRealRowCount();

    }
    public void cleanUp() {
    }
}
