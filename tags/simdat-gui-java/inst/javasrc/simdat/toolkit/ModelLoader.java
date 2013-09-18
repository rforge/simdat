package simdat.toolkit;

import simdat.SimDat;
import org.rosuda.JGR.RController;

import java.awt.FlowLayout;
import java.beans.PropertyChangeEvent;
import java.beans.PropertyChangeListener;
import java.io.File;

import javax.swing.JFileChooser;
import javax.swing.JFrame;
import javax.swing.JLabel;
// import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JTextField;
import javax.swing.filechooser.FileFilter;

// import org.rosuda.JGR.editor.Editor;
import org.rosuda.JGR.toolkit.ExtensionFileFilter;
import org.rosuda.JGR.toolkit.FileSelector;
import org.rosuda.JGR.util.ErrorMsg;
// import org.rosuda.REngine.REXPMismatchException;
// import org.rosuda.REngine.REngineException;

public class ModelLoader extends JFrame implements PropertyChangeListener {

	/**
	 *
	 */
	private static final long serialVersionUID = -7945677424441713542L;
	private static String extensions[][] = new String[][] { { "rda", "rdata" }, { "robj" }  };
	private static String extensionDescription[] = new String[] { "R (*.rda *.rdata)", "R dput() (*.robj)" };
	private JTextField rModelNameField;
	private String rName;
	private FileSelector fileDialog;

	public ModelLoader() {
		try {
			FileFilter extFilter;
			fileDialog = new FileSelector(this, "Load Model", FileSelector.LOAD, null, true);
			JFileChooser chooser = fileDialog.getJFileChooser();
			for (int i = 0; i < extensionDescription.length; i++) {
				extFilter = new ExtensionFileFilter(extensionDescription[i], extensions[i]);
				chooser.addChoosableFileFilter(extFilter);
			}
			chooser.setFileFilter(chooser.getAcceptAllFileFilter());
			JPanel namePanel = new JPanel(new FlowLayout(FlowLayout.LEFT));
			namePanel.add(new JLabel("Set name: "));
			rModelNameField = new JTextField(20);
			namePanel.add(rModelNameField);
			fileDialog.addFooterPanel(namePanel);
			fileDialog.getJFileChooser().addPropertyChangeListener(this);
			fileDialog.setVisible(true);
			if (fileDialog.getFile() == null)
				return;
			rName = rModelNameField.getText();
			if (rName.length() == 0)
				rName = (fileDialog.getFile().indexOf(".") <= 0 ? getUniqueName(fileDialog.getFile()) :
						getUniqueName(fileDialog.getFile().substring(0, fileDialog.getFile().indexOf("."))));
			rName = RController.makeValidVariableName(rName);
			loadModel(addSlashes(fileDialog.getFile()), fileDialog.getDirectory(), rName);
		} catch (Exception er) {
			new ErrorMsg(er);
		}

	}

	public void loadModel(String fileName, String directory, String var) {
		if (fileName.toLowerCase().endsWith(".rda") || fileName.toLowerCase().endsWith(".rdata"))
			loadRdaFile(fileName, directory);
		else if (fileName.toLowerCase().endsWith(".robj"))
			loadDputFile(fileName, directory);
                /*
		else if (fileName.toLowerCase().endsWith(".r")) {
			Editor temp = new Editor((directory + fileName).replace('\\', '/'), true);
			temp.dispose();
		} else if (fileName.toLowerCase().endsWith(".txt") | fileName.toLowerCase().endsWith(".csv"))
			loadTxtFile(fileName, directory, var);
		else {
			try {
				RController.loadPackage("foreign");
				if (fileName.toLowerCase().endsWith(".sav"))
					execute(var + " <- read.spss('" + (directory + fileName).replace('\\', '/') + "',to.data.frame=TRUE)", true);
				else if (fileName.toLowerCase().endsWith(".xpt") | fileName.toLowerCase().endsWith(".xport"))
					execute(var + " <- read.xport('" + (directory ).replace('\\', '/')+ fileName + "')", true);
				else if (fileName.toLowerCase().endsWith(".dta"))
					execute(var + " <- read.dta('" + (directory ).replace('\\', '/')+ fileName + "')", true);
				else if (fileName.toLowerCase().endsWith(".arff"))
					execute(var + " <- read.arff('" + (directory ).replace('\\', '/')+ fileName + "')", true);
				else if (fileName.toLowerCase().endsWith(".rec"))
					execute(var + " <- read.epiinfo('" + (directory ).replace('\\', '/')+ fileName + "')", true);
				else if (fileName.toLowerCase().endsWith(".mtp"))
					execute(var + " <- as.data.frame(read.mtp('" + (directory ).replace('\\', '/')+ fileName + "'))", true);
				else if (fileName.toLowerCase().endsWith(".s3"))
					execute("data.restore('" + (directory ).replace('\\', '/')+ fileName + "',print=TRUE)", true);
				else if (fileName.toLowerCase().endsWith(".syd") || fileName.toLowerCase().endsWith(".sys"))
					execute(var + " <- read.systat('" + (directory ).replace('\\', '/')+ fileName + "')", true);
				else if (fileName.toLowerCase().endsWith(".dbf"))
					execute(var + " <- read.dbf('" + (directory ).replace('\\', '/')+ fileName + "')", true);
				else if (fileName.toLowerCase().endsWith(".xls")||fileName.toLowerCase().endsWith(".xlsx")){
					RController.loadPackage("XLConnect");
					String sheet = JOptionPane.showInputDialog("Which worksheet should be loaded?", "1");
					JGR.MAINRCONSOLE.executeLater("library(XLConnect)\n" + var + " <- readWorksheet(loadWorkbook('" + (directory ).replace('\\', '/')+ fileName + "'),sheet="+sheet+")", true);
				}else {
					int opt = JOptionPane.showConfirmDialog(this, "Unknown File Type.\nWould you like to try to open it as a text data file?");
					if (opt == JOptionPane.OK_OPTION)
						loadTxtFile(fileName, directory, var);
				}
			} catch (Exception e) {
				new ErrorMsg(e);
			}
		}
                */
	}

	public void loadRdaFile(String fileName, String directory) {
		String cmd = "print(load(\"" + (directory.replace('\\', '/') + fileName) + "\"))";
                SimDat.eval("cat('The following models have been loaded:\\\n')");
                /*
		try {
			SimDat.eval("cat('The following data objects have been loaded:\\\n')");
		} catch (REngineException e) {
			new ErrorMsg(e);
		} catch (REXPMismatchException e) {
			new ErrorMsg(e);
		}
                 */
		execute(cmd, true);
	}

	public void loadDputFile(String fileName, String directory) {
		String var = (fileName.indexOf(".") <= 0 ? getUniqueName(fileName) : getUniqueName(fileName.substring(0,
				fileName.indexOf("."))));
		execute(var + " <- dget('" + (directory + fileName).replace('\\', '/') + "')", true);
	}

        /*
	public void loadTxtFile(String fileName, String directory, String rName) {
		TxtTableLoader.run(directory.replace('\\','/') + fileName, rName);
	}
         */

	public void execute(String cmd,boolean show){
		//JGR.MAINRCONSOLE.execute(cmd,show);
                SimDat.execute(cmd,show);
	}

	public String getUniqueName(String name){
		//return JGR.MAINRCONSOLE.getUniqueName(name);
                return SimDat.getUniqueName(name);
	}

	public String getModelName() {
		return rName;
	}

	/**
	 * propertyChange: handle propertyChange, used for setting the name where
	 * the set should be assigned to.
	 */
	public void propertyChange(PropertyChangeEvent e) {
		File file = fileDialog.getSelectedFile();
		if (e.getPropertyName() == "SelectedFileChangedProperty") {
			if (file != null && !file.isDirectory()
					&& !(file.getName().toLowerCase().endsWith(".rdata") || file.getName().toLowerCase().endsWith(".rda"))) {
				String name = file.getName().replaceAll("\\..*", "");
				name = getUniqueName(name);
				rModelNameField.setText(name);
			} else
				rModelNameField.setText("");
		}
	}
	private static String addSlashes(String str){
		if(str==null) return "";

		StringBuffer s = new StringBuffer(str);
		for(int i = 0; i < s.length(); i++){
			if(s.charAt (i) == '\"')
				s.insert(i++, '\\');
			else if(s.charAt (i) == '\'')
				s.insert(i++, '\\');
		}

		return s.toString();
	}
}