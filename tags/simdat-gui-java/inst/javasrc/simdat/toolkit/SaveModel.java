package simdat.toolkit;

import javax.swing.JFileChooser;
// import javax.swing.JFrame;
import javax.swing.filechooser.FileFilter;

import org.rosuda.JGR.toolkit.ExtensionFileFilter;
import org.rosuda.JGR.toolkit.FileSelector;
import org.rosuda.deducer.Deducer;

public class SaveModel  {

	/**
	 * 
	 */
	private static final long serialVersionUID = -5513844930423188258L;
	private static String extensions[][] = new String[][] { { "rda", "rdata" }, { "robj" }};
	private static String extensionDescription[] = new String[] { "R (*.rda *.rdata)", "R dput() (*.robj)"};

	public SaveModel(String modelName) {
		JFileChooser chooser = null;
		FileFilter extFilter = null;
		FileSelector fileDialog = new FileSelector(null, "Save Data", FileSelector.SAVE);
		if (fileDialog.isSwing()) {
			chooser = fileDialog.getJFileChooser();
			for (int i = 0; i < extensionDescription.length; i++) {
				extFilter = new ExtensionFileFilter(extensionDescription[i], extensions[i]);
				chooser.addChoosableFileFilter(extFilter);
			}
			chooser.setFileFilter(chooser.getAcceptAllFileFilter());
		}
		fileDialog.setVisible(true);
		if (fileDialog.getFile() == null)
			return;
		String fileName = fileDialog.getDirectory() + fileDialog.getFile();
		fileName = fileName.replace('\\', '/');
		if (fileDialog.getFile() == null)
			return;
		if (!fileDialog.isSwing()) {
			if (!fileName.toLowerCase().endsWith(".robj"))
				fileName = fileName.concat(".robj");
			Deducer.execute("dput(" + modelName + ",'" + fileName + "')", true);
		} else {
			if (fileName.toLowerCase().endsWith(".rda") || fileName.toLowerCase().endsWith(".rdata") ||
					chooser.getFileFilter().getDescription().equals(extensionDescription[0])) {
				if (!fileName.toLowerCase().endsWith(".rda") && !fileName.toLowerCase().endsWith(".rdata"))
					fileName = fileName.concat(".rda");
				Deducer.execute("save(" + modelName + ",file='" + fileName + "')", true);
			} else if (fileName.toLowerCase().endsWith(".robj") ||
						chooser.getFileFilter().getDescription().equals(extensionDescription[1])) {
				if (!fileName.toLowerCase().endsWith(".robj"))
					fileName = fileName.concat(".robj");
				Deducer.execute("dput(" + modelName + ",'" + fileName + "')", true);
			} /*else if (fileName.toLowerCase().endsWith(".csv") ||
						chooser.getFileFilter().getDescription().equals(extensionDescription[2])) {
				if (!fileName.toLowerCase().endsWith(".csv"))
					fileName = fileName.concat(".csv");
				Deducer.execute("write.csv(" + modelName + ",'" + fileName + "')", true);
			} else if (fileName.toLowerCase().endsWith(".txt") || 
						chooser.getFileFilter().getDescription().equals(extensionDescription[3])) {
				if (!fileName.toLowerCase().endsWith(".txt"))
					fileName = fileName.concat(".txt");
				Deducer.execute("write.table(" + modelName + ",'" + fileName + "',sep='\\t')", true);
			} else {
				Deducer.requirePackage("foreign");
				if (fileName.toLowerCase().endsWith(".dbf") || 
						chooser.getFileFilter().getDescription().equals(extensionDescription[4])) {
					if (!fileName.toLowerCase().endsWith(".dbf"))
						fileName = fileName.concat(".dbf");
					Deducer.execute("write.dbf(" + modelName + ",'" + fileName + "')", true);
				} else if (fileName.toLowerCase().endsWith(".dta") ||
						chooser.getFileFilter().getDescription().equals(extensionDescription[5])) {
					if (!fileName.toLowerCase().endsWith(".dta"))
						fileName = fileName.concat(".dta");
					Deducer.execute("write.dta(" + modelName + ",'" + fileName + "')", true);
				} else if (fileName.toLowerCase().endsWith(".arff") ||
						chooser.getFileFilter().getDescription().equals(extensionDescription[6])) {
					if (!fileName.toLowerCase().endsWith(".arff"))
						fileName = fileName.concat(".arff");
					Deducer.execute("write.arff(" + modelName + ",'" + fileName + "')", true);
				} else {
					if (!fileName.toLowerCase().endsWith(".robj"))
						fileName = fileName.concat(".robj");
					Deducer.execute("dput(" + modelName + ",'" + fileName + "')", true);
				}
			}
                           *
                           */
		}
	}

}
