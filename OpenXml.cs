using DocumentFormat.OpenXml.Packaging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using S = DocumentFormat.OpenXml.Spreadsheet.Sheets;
using E = DocumentFormat.OpenXml.OpenXmlElement;
using A = DocumentFormat.OpenXml.OpenXmlAttribute;
using DocumentFormat.OpenXml;
using DocumentFormat.OpenXml.Spreadsheet;
using System.Data;

namespace ConsoleApplication1
{
    class Program
    {
        static void Main(string[] args)
        {
            var dt = new DataTable();
            var fN = @"C:\Users\david\OneDrive\Documents\Book1.xlsx";
            using (SpreadsheetDocument mySpreadsheet = SpreadsheetDocument.Open(fN, false))
            {
                WorkbookPart workbookPart = mySpreadsheet.WorkbookPart;
                IEnumerable<Sheet> sheets = mySpreadsheet.WorkbookPart.Workbook.GetFirstChild<Sheets>().Elements<Sheet>();
                string relationshipId = sheets.First().Id.Value;
                WorksheetPart worksheetPart = (WorksheetPart)mySpreadsheet.WorkbookPart.GetPartById(relationshipId);
                Worksheet workSheet = worksheetPart.Worksheet;
                SheetData sheetData = workSheet.GetFirstChild<SheetData>();
                IEnumerable<Row> rows = sheetData.Descendants<Row>();

                foreach (Cell cell in rows.ElementAt(0))
                {
                    Console.WriteLine(GetCellValue(mySpreadsheet, cell));
                    //dt.Columns.Add(GetCellValue(mySpreadsheet, cell));
                }

                foreach (Row row in rows) //this will also include your header row...
                {
                    //DataRow tempRow = dt.NewRow();
                    //for (int i = 0; i < row.Descendants<Cell>().Count(); i++)
                    //{
                        Console.WriteLine(GetCellValue(mySpreadsheet, row.Descendants<Cell>().First()));
                    Console.WriteLine(GetCellValue(mySpreadsheet, row.Descendants<Cell>().Last()));
                    //Console.WriteLine(GetCellValue(mySpreadsheet, row.Descendants<Cell>().ElementAt(i - 1)));
                    //tempRow[i] = GetCellValue(mySpreadsheet, row.Descendants<Cell>().ElementAt(i - 1));
                    //}
                    //dt.Rows.Add(tempRow);
                }

                //S sheets = mySpreadsheet.WorkbookPart.Workbook.Sheets;
                //foreach (E sheet in sheets)
                //{
                //    var sheep = (DocumentFormat.OpenXml.Spreadsheet.Sheet)sheet;
                //    Console.WriteLine(sheep.Name);
                //    foreach (A attr in sheet.GetAttributes())
                //    {
                //        Console.WriteLine("{0}: {1}", attr.LocalName, attr.Value);
                //    }
                //}

                //WorkbookPart workbookPart = mySpreadsheet.WorkbookPart;
                //WorksheetPart worksheetPart = workbookPart.WorksheetParts.First();
                //OpenXmlReader reader = OpenXmlReader.Create(worksheetPart);
                //string text;
                //while (reader.Read())
                //{
                //    if (reader.ElementType == typeof(CellValue))
                //    {
                //        text = reader.GetText();
                //        Console.WriteLine(text + " ");
                //    }
                //}

                ////create the object for workbook part  
                //WorkbookPart wbPart = mySpreadsheet.WorkbookPart;
                ////statement to get the count of the worksheet  
                //int worksheetcount = mySpreadsheet.WorkbookPart.Workbook.Sheets.Count();
                ////statement to get the sheet object  
                //Sheet mysheet = (Sheet)mySpreadsheet.WorkbookPart.Workbook.Sheets.ChildElements.GetItem(0);         
                ////statement to get the worksheet object by using the sheet id  
                //Worksheet Worksheet = ((WorksheetPart)wbPart.GetPartById(mysheet.Id)).Worksheet;
                ////Note: worksheet has 8 children and the first child[1] = sheetviewdimension,....child[4]=sheetdata  
                //int wkschildno = 3;
                ////statement to get the sheetdata which contains the rows and cell in table  
                //SheetData Rows = (SheetData)Worksheet.ChildElements.GetItem(wkschildno);
                ////getting the row as per the specified index of getitem method  
                //Row currentrow = (Row)Rows.ChildElements.GetItem(1);
                ////getting the cell as per the specified index of getitem method  
                //Cell currentcell = (Cell)currentrow.ChildElements.GetItem(1);
                ////statement to take the integer value  
                //string currentcellvalue = currentcell.InnerText;

            }
        }

        public static string GetCellValue(SpreadsheetDocument document, Cell cell)
        {
            SharedStringTablePart stringTablePart = document.WorkbookPart.SharedStringTablePart;
            string value = cell.CellValue.InnerXml;

            if (cell.DataType != null && cell.DataType.Value == CellValues.SharedString)
            {
                return stringTablePart.SharedStringTable.ChildElements[Int32.Parse(value)].InnerText;
            }
            else
            {
                return value;
            }
        }
    }
}
