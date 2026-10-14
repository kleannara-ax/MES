using System;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Forms;

using Infragistics.Win.UltraWinGrid;
using Infragistics.Win;
using System.Drawing;

using Infragistics.Win.UltraWinScrollBar;
using Infragistics.Win.UltraWinMaskedEdit;
using Infragistics.Win.UltraWinGrid.ExcelExport;

using System.Reflection;
using System.Runtime.InteropServices;

namespace SAMMI
{
    internal class FakeCaptionSummary : ICustomSummaryCalculator
    {
        public FakeCaptionSummary()
        {
            // Empty constructor
        }
        // Called at the start of the custom summary calculation
        public void BeginCustomSummary(SummarySettings summarySettings, RowsCollection rows)
        { }
        // Called for each row in band of this summary
        public void AggregateCustomSummary(SummarySettings summarySettings, UltraGridRow row)
        { }
        // Called to get the return value to put in the SummaryRpw at the specified column
        public object EndCustomSummary(SummarySettings summarySettings, RowsCollection rows)
        {
            return "";
        }
    }
    public class UltraComboUtil
    {
        public void DataBind(UltraCombo ultraCombo, DataTable DtSouce)
        {
            String[] strColName = new String[0];
            DataBind(ultraCombo, DtSouce, strColName);
        }

        public void DataBind(UltraCombo ultraCombo, DataTable DtSouce, String[] strColName)
        {
            if (strColName.Length > 0)
            {
                ultraCombo.DisplayMember = strColName[0];
                ultraCombo.ValueMember = strColName[1];

            }
            else
            {
                ultraCombo.DisplayMember = DtSouce.Columns[0].ColumnName;
                ultraCombo.ValueMember = DtSouce.Columns[1].ColumnName;
            }

            ultraCombo.DataSource = DtSouce;

            for (int i = 0; i < ultraCombo.DisplayLayout.Bands.Count; i++)
            {
                ultraCombo.DisplayLayout.Bands[i].PerformAutoResizeColumns(false, PerformAutoSizeType.AllRowsInBand, AutoResizeColumnWidthOptions.All);

                for (int j = 0; j < ultraCombo.DisplayLayout.Bands[i].Columns.Count; j++)
                {
                    ultraCombo.DisplayLayout.Bands[i].Columns[j].CellAppearance.TextHAlign = Infragistics.Win.HAlign.Center;
                }
            }
        }
    }


    public class UltraGridUtil
    {
        public static int bandIndex = 0;

        public void InitializeGrid(UltraGrid ultraGrid)
        {
            ultraGrid.DisplayLayout.Override.RowAlternateAppearance.BackColor = Color.FromArgb(0xcf, 250, 250);
            InitializeGrid(ultraGrid, true, true, true, "", false);
        }

        public void InitializeGrid(UltraGrid ultraGrid, bool addContextMenu, bool allowEditable, bool extendLastCol, string gridCaption, bool activeRowWhiteColor)
        {
            ultraGrid.DisplayLayout.ClearGroupByColumns();
            ultraGrid.UseFlatMode = DefaultableBoolean.True;
            if (gridCaption == "")
            {
                ultraGrid.DisplayLayout.CaptionVisible = DefaultableBoolean.False;
            }
            else
            {
                ultraGrid.DisplayLayout.CaptionVisible = DefaultableBoolean.True;
                ultraGrid.Text = gridCaption;
            }
            ultraGrid.DisplayLayout.AutoFitStyle = AutoFitStyle.None;
            if (extendLastCol)
            {
                ultraGrid.DisplayLayout.AutoFitStyle = AutoFitStyle.ExtendLastColumn;
            }
            ultraGrid.DisplayLayout.Appearance.BorderColor = Color.Black;
            ultraGrid.DisplayLayout.ColumnChooserEnabled = DefaultableBoolean.True;
            ultraGrid.DisplayLayout.CaptionAppearance.BackColor = Color.Red;
            ultraGrid.DisplayLayout.BorderStyle = UIElementBorderStyle.Rounded1;
            ultraGrid.DisplayLayout.BorderStyleCaption = UIElementBorderStyle.Solid;
            ultraGrid.DisplayLayout.GroupByBox.Hidden = true;
            ultraGrid.DisplayLayout.InterBandSpacing = 10;
            ultraGrid.DisplayLayout.LoadStyle = LoadStyle.LoadOnDemand;
            ultraGrid.DisplayLayout.ScrollStyle = ScrollStyle.Immediate;
            ultraGrid.DisplayLayout.ScrollBarLook.ViewStyle = ScrollBarViewStyle.WindowsVista;
            ultraGrid.DisplayLayout.TabNavigation = TabNavigation.NextCell;
            ultraGrid.DisplayLayout.ViewStyle = ViewStyle.MultiBand;
            ultraGrid.DisplayLayout.ViewStyleBand = ViewStyleBand.OutlookGroupBy;
            ultraGrid.DisplayLayout.Override.AllowUpdate = DefaultableBoolean.False;
            ultraGrid.DisplayLayout.Override.AllowGroupMoving = AllowGroupMoving.WithinBand;
            ultraGrid.DisplayLayout.Override.AllowRowSummaries = AllowRowSummaries.False;
            ultraGrid.DisplayLayout.Override.AllowColMoving = AllowColMoving.WithinBand;
            ultraGrid.DisplayLayout.Override.ButtonStyle = UIElementButtonStyle.WindowsXPCommandButton;
            ultraGrid.DisplayLayout.Override.BorderStyleCell = UIElementBorderStyle.Solid;
            ultraGrid.DisplayLayout.Override.BorderStyleRow = UIElementBorderStyle.Solid;
            ultraGrid.DisplayLayout.Override.BorderStyleRowSelector = UIElementBorderStyle.Solid;
            ultraGrid.DisplayLayout.Override.BorderStyleHeader = UIElementBorderStyle.Solid;
            ultraGrid.DisplayLayout.Override.BorderStyleFilterCell = UIElementBorderStyle.Solid;
            ultraGrid.DisplayLayout.Override.BorderStyleFilterOperator = UIElementBorderStyle.Solid;
            ultraGrid.DisplayLayout.Override.BorderStyleFilterRow = UIElementBorderStyle.Solid;
            ultraGrid.DisplayLayout.Override.BorderStyleSpecialRowSeparator = UIElementBorderStyle.Solid;
            ultraGrid.DisplayLayout.Override.BorderStyleSummaryFooter = UIElementBorderStyle.Solid;
            ultraGrid.DisplayLayout.Override.BorderStyleSummaryFooterCaption = UIElementBorderStyle.Solid;
            ultraGrid.DisplayLayout.Override.BorderStyleSummaryValue = UIElementBorderStyle.Solid;
            ultraGrid.DisplayLayout.Override.BorderStyleTemplateAddRow = UIElementBorderStyle.Solid;
            ultraGrid.DisplayLayout.Override.CellClickAction = CellClickAction.EditAndSelectText;
            ultraGrid.DisplayLayout.Override.CellMultiLine = DefaultableBoolean.False;
            ultraGrid.DisplayLayout.Override.CellAppearance.TextVAlign = VAlign.Middle;
            ultraGrid.DisplayLayout.Override.CellButtonAppearance.TextVAlign = VAlign.Middle;
            ultraGrid.DisplayLayout.Override.DefaultRowHeight = 0x15;
            ultraGrid.DisplayLayout.Override.ExpansionIndicator = ShowExpansionIndicator.Default;
            ultraGrid.DisplayLayout.Override.HeaderClickAction = HeaderClickAction.SortMulti;
            ultraGrid.DisplayLayout.Override.HeaderStyle = HeaderStyle.WindowsXPCommand;
            ultraGrid.DisplayLayout.Override.RowSelectorHeaderStyle = RowSelectorHeaderStyle.SeparateElement;
            ultraGrid.DisplayLayout.Override.RowSelectorNumberStyle = RowSelectorNumberStyle.None;
            ultraGrid.DisplayLayout.Override.RowSelectorAppearance.TextHAlign = HAlign.Left;
            ultraGrid.DisplayLayout.Override.RowSelectors = DefaultableBoolean.True;
            ultraGrid.DisplayLayout.Override.RowSelectorStyle = HeaderStyle.WindowsVista;
            ultraGrid.DisplayLayout.Override.TipStyleCell = TipStyle.Show;
            ultraGrid.DisplayLayout.Override.TipStyleHeader = TipStyle.Show;
            ultraGrid.DisplayLayout.Override.TipStyleScroll = TipStyle.Show;
            ultraGrid.DisplayLayout.Override.WrapHeaderText = DefaultableBoolean.True;
            ultraGrid.DisplayLayout.MaxColScrollRegions = 2;
            ultraGrid.DisplayLayout.MaxRowScrollRegions = 2;
            ultraGrid.DisplayLayout.SplitterBarHorizontalAppearance.BackColor = Color.DarkBlue;
            ultraGrid.DisplayLayout.SplitterBarVerticalAppearance.BackColor = Color.DarkBlue;

            //ultraGrid.DisplayLayout.Override.ColumnAutoSizeMode = ColumnAutoSizeMode.None;
            //ultraGrid.DisplayLayout.Override.AutoResizeColumnWidthOptions = AutoResizeColumnWidthOptions.IncludeCells;

            ultraGrid.DisplayLayout.Override.RowSelectorNumberStyle = RowSelectorNumberStyle.VisibleIndex;
            ultraGrid.DisplayLayout.Override.RowSelectorWidth = 40;
            ultraGrid.DisplayLayout.Override.RowSelectorAppearance.TextHAlign = Infragistics.Win.HAlign.Center;
            ultraGrid.DisplayLayout.Override.RowSelectorAppearance.TextVAlign = Infragistics.Win.VAlign.Middle;

            ultraGrid.DisplayLayout.Override.FixedHeaderIndicator = FixedHeaderIndicator.None;
            ultraGrid.DisplayLayout.UseFixedHeaders = true;
            ultraGrid.DisplayLayout.Override.AllowColSizing = AllowColSizing.Free;
            if (allowEditable)
            {
                ultraGrid.DisplayLayout.Override.AllowUpdate = DefaultableBoolean.True;
                //ultraGrid.DisplayLayout.Override.SelectTypeRow = SelectType.None;
                ultraGrid.DisplayLayout.Override.SelectTypeCell = SelectType.ExtendedAutoDrag;
            }
            ultraGrid.DisplayLayout.Override.SupportDataErrorInfo = Infragistics.Win.UltraWinGrid.SupportDataErrorInfo.RowsOnly;

        }

        public void SetSummaryColumns(UltraGrid Grid, string Title, int TitlePos, string[] sumColumns
            , SummaryType sumType = SummaryType.Sum, SummaryDisplayAreas sumPos = SummaryDisplayAreas.Top
            , string SumFormat = "#,##0.##", SummaryDisplayAreas SumDisplayPos = SummaryDisplayAreas.Top,  Color? SumBack = null, Color? SumFore = null)
        {
            UltraGridBand band = Grid.DisplayLayout.Bands[0];
            string sTilleName = SAMMI.Common.Lang == "KO" ? Title : SAMMI.Common.getLangText(Title); 

            if (band.Summaries.Count <= 0)
                band.Summaries.Add(sTilleName, SummaryType.Custom, new FakeCaptionSummary(), band.Columns[TitlePos], SummaryPosition.UseSummaryPositionColumn, band.Columns[TitlePos]);

            int i = 0;

            foreach (var column in band.Columns.Cast<UltraGridColumn>())
            {
                int index = Array.FindIndex(sumColumns, item => item == column.Key.ToUpper());

                if (index >= 0)
                {
                    SummarySettings settings = band.Summaries.Add("SUM([" + column + "])",
                     SummaryType.Custom, new FakeCaptionSummary(), band.Columns[i],
                     SummaryPosition.UseSummaryPositionColumn, band.Columns[i]);
                    settings.SourceColumn = band.Columns[i];

                    settings.DisplayFormat = "{0:" + SumFormat + "}";
                    settings.SourceColumn.Format = SumFormat;
                    settings.SummaryPositionColumn.Format = SumFormat;

                    settings.SummaryType = sumType;

                    settings.SummaryDisplayArea = SumDisplayPos;
                    settings.Appearance.TextHAlign = HAlign.Right;
                    settings.Appearance.FontData.Bold = DefaultableBoolean.True;
                    settings.Appearance.BackColor = SumBack ?? Color.Empty;
                    settings.Appearance.ForeColor = SumFore ?? Color.Black;
                }
                else
                {
                    // 타이틀 위치 컬럼 일경우
                    if (i == TitlePos)
                    {
                        band.Override.SummaryFooterCaptionVisible = DefaultableBoolean.False;
                        band.Override.SummaryFooterAppearance.FontData.SizeInPoints =
                            Grid.DisplayLayout.Appearance.FontData.SizeInPoints;
                        Grid.DisplayLayout.ScrollBounds = ScrollBounds.ScrollToFill;

                        band.Summaries[0].DisplayFormat = sTilleName;
                        band.Summaries[0].Appearance.TextHAlign = HAlign.Center;
                        band.Summaries[0].SummaryDisplayArea = SumDisplayPos;
                        band.Summaries[0].Appearance.FontData.Bold = DefaultableBoolean.True;
                        band.Summaries[0].Appearance.BackColor = SumBack ?? Color.Empty;
                        band.Summaries[0].Appearance.ForeColor = SumFore ?? Color.Black;
                    }
                }
                i++;
            }
        }

        /// <summary>
        /// 지정한 그리드 컬럼의 그룹을 설정합니다.(*부분그룹병합)
        /// </summary>
        /// <param name="Grid">대상 그리드</param>
        /// <param name="GroupKey">그룹 키</param>
        /// <param name="GroupCaption">그룹 명</param>
        /// <param name="MergeColumns">그룹 대상 컬럼</param>
        /// <param name="Columns">그리드 컬럼(현재 사용하지 않음)</param>
        /// <param name="AlignHeader">그룹 명 정렬</param>
        public void GridHeaderMerge(UltraGrid Grid, string GroupKey, string GroupCaption, string[] MergeColumns, string[] Columns = null, Infragistics.Win.HAlign AlignHeader = HAlign.Center)
        {
            UltraGridBand band = Grid.DisplayLayout.Bands[0];

            //Arrange the band's column in Group Layout style
            Grid.DisplayLayout.Bands[0].RowLayoutStyle = RowLayoutStyle.GroupLayout;

            //Enbale Column/Group moving
            //Grid.DisplayLayout.Override.AllowRowLayoutColMoving = Infragistics.Win.Layout.GridBagLayoutAllowMoving.AllowAll;
            int i = 0;
            for (i = 0; i < MergeColumns.Length; i++)
            {
                MergeColumns[i] = MergeColumns[i].ToUpper();
            }
            UltraGridGroup group = null;
            foreach (var column in band.Columns.Cast<UltraGridColumn>())
            {
                int index = Array.FindIndex(MergeColumns, item => item == column.Key.ToUpper());

                if (index >= 0)
                {
                    if (index == 0)
                    {
                        group = band.Groups.Add(GroupKey, SAMMI.Common.Lang == "KO" ? GroupCaption : SAMMI.Common.getLangText(GroupCaption));
                    }

                    band.Columns[column.Key].RowLayoutColumnInfo.OriginX = 2 * index;
                    band.Columns[column.Key].RowLayoutColumnInfo.SpanX = 2;
                    band.Columns[column.Key].RowLayoutColumnInfo.SpanY = 2;

                    if (group != null)
                    {
                        band.Columns[column.Key].RowLayoutColumnInfo.ParentGroup = group;
                        if (band.Columns[column.Key].RowLayoutColumnInfo.ParentGroup.RowLayoutGroupInfo.OriginX == -1)
                        {
                            band.Columns[column.Key].RowLayoutColumnInfo.ParentGroup.RowLayoutGroupInfo.OriginX = Convert.ToInt32(i * 2);
                            band.Groups[group.Key].Header.Appearance.TextHAlign = AlignHeader;
                        }
                    }
                }
                else
                {
                    if (band.Columns[column.Key].RowLayoutColumnInfo.ParentGroup == null)
                    {
                        band.Columns[column.Key].RowLayoutColumnInfo.OriginX = 2*i;
                        band.Columns[column.Key].RowLayoutColumnInfo.SpanX = 2;
                        band.Columns[column.Key].RowLayoutColumnInfo.SpanY = 4;
                    }
                }
                i++;
            }
        }

        /// <summary>
        /// 그리드 헤드 2단 Vertical Merge기능
        /// </summary>
        /// <param name="Grid">적용 그리드</param>
        /// <param name="Columns">적용 컬럼명</param>
        /// <param name="nFirst">적용 컬럼의 Merge 하고자 하는 시작 위치</param>
        /// <param name="nLast">적용 컬럼의 Merge 하고자 하는 끝 위치</param>
        /// <param name="AlignHeader">Header Label Align</param>
        public void GridHeaderMergeVertical(UltraGrid Grid, string[] Columns, int nFirst, int nLast, Infragistics.Win.HAlign AlignHeader = HAlign.Center)
        {
            UltraGridBand band = Grid.DisplayLayout.Bands[0];

            //Arrange the band's column in Group Layout style
            Grid.DisplayLayout.Bands[0].RowLayoutStyle = RowLayoutStyle.GroupLayout;

            //Enbale Column/Group moving
            //Grid.DisplayLayout.Override.AllowRowLayoutColMoving = Infragistics.Win.Layout.GridBagLayoutAllowMoving.AllowAll;

            for (int i = nFirst; i <= nLast; i++)
            {
                Columns[i] = Columns[i].ToUpper();
                band.Columns[Columns[i]].RowLayoutColumnInfo.OriginX = i * 2;
                band.Columns[Columns[i]].RowLayoutColumnInfo.OriginY = 0;

                band.Columns[Columns[i]].RowLayoutColumnInfo.SpanX = 2;
                band.Columns[Columns[i]].RowLayoutColumnInfo.SpanY = 4;
                band.Columns[Columns[i]].RowLayoutColumnInfo.LabelSpan = 4;
                band.Columns[Columns[i]].Header.Appearance.TextHAlign = AlignHeader;
                   
            }
        }

        public void GridHeaderMergeVertical(UltraGrid Grid, int nFirst, int nLast, Infragistics.Win.HAlign AlignHeader = HAlign.Center)
        {
            UltraGridBand band = Grid.DisplayLayout.Bands[0];

            //Arrange the band's column in Group Layout style
            Grid.DisplayLayout.Bands[0].RowLayoutStyle = RowLayoutStyle.GroupLayout;

            //Enbale Column/Group moving
            //Grid.DisplayLayout.Override.AllowRowLayoutColMoving = Infragistics.Win.Layout.GridBagLayoutAllowMoving.AllowAll;
            int i = 0;

            foreach (var column in band.Columns.Cast<UltraGridColumn>())
            {
                if (i >= nFirst && i <= nLast)
                {
                    band.Columns[column.Key].RowLayoutColumnInfo.OriginX = i*2;
                    band.Columns[column.Key].RowLayoutColumnInfo.OriginY = 0;

                    band.Columns[column.Key].RowLayoutColumnInfo.SpanX = 2;
                    band.Columns[column.Key].RowLayoutColumnInfo.SpanY = 4;
                    band.Columns[column.Key].RowLayoutColumnInfo.LabelSpan = 4;
                    band.Columns[column.Key].Header.Appearance.TextHAlign = AlignHeader;
                }
                i++;
            }
        }

        public void InitColumnUltraGrid(UltraGrid ultraGrid, string columnName, string caption, bool colNotNullable=false, GridColDataType_emu colDataType = GridColDataType_emu.VarChar, int columnWidth = 100, int maxLength = 0, HAlign HAlign = Infragistics.Win.HAlign.Default, bool visible = true, bool editable = false, string formatString = "", string editMask = "", string maxValue = "", string minValue = "", string regexPattern = "")
        {
            try
            {
                columnName = columnName.ToUpper();

                if (caption != null)
                {
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns.Add(columnName, Common.getLangText(caption));
                }
                else
                {
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns.Add(columnName, columnName);
                }

                //  ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].AutoSizeMode = ColumnAutoSizeMode.None;
                ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Hidden = !visible;
                ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MergedCellStyle = MergedCellStyle.Never;
                ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaskClipMode = MaskMode.IncludeLiterals;
                ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaskDisplayMode = MaskMode.IncludeLiterals;
                ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaskDataMode = MaskMode.IncludeLiterals;
                if (ultraGrid.DisplayLayout.Override.AllowUpdate != DefaultableBoolean.True)
                {
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].CellActivation = Activation.NoEdit;
                }
                else if (!editable)
                {
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].CellActivation = Activation.NoEdit;
                }
                else
                {
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].CellActivation = Activation.AllowEdit;
                }

                SetUserDataGrid(ultraGrid, columnName, colNotNullable, colDataType, HAlign, caption, columnWidth, maxLength, formatString, editMask, maxValue, minValue, "");

            }
            catch (Exception exception)
            {
                MessageBox.Show(exception.Message + Environment.NewLine + "[" + ultraGrid.Name + "] " + columnName , "Grid Initiallizing Error", MessageBoxButtons.OK,
                    MessageBoxIcon.Error);
            }
        }

        public void InitColumnUltraGrid(UltraGrid ultraGrid, string columnName, string caption, bool colNotNullable, GridColDataType_emu colDataType, int columnWidth, bool visible, bool editable)
        {
            InitColumnUltraGrid( ultraGrid,  columnName,  caption,  colNotNullable, colDataType,  columnWidth, 0, Infragistics.Win.HAlign.Center,  visible,  editable);
            //columnName = columnName.ToUpper();
            //if ((caption != null) && (caption != ""))
            //{
            //    ultraGrid.DisplayLayout.Bands[bandIndex].Columns.Add(columnName, Common.getLangText(caption));
            //}
            //else
            //{
            //    ultraGrid.DisplayLayout.Bands[bandIndex].Columns.Add(columnName, columnName);
            //}
            //// ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].AutoSizeMode = ColumnAutoSizeMode.None;
            //ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Hidden = !visible;
            //ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MergedCellStyle = MergedCellStyle.Never;
            //ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaskClipMode = MaskMode.IncludeLiterals;
            //ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaskDisplayMode = MaskMode.IncludeLiterals;
            //ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaskDataMode = MaskMode.IncludeLiterals;
            //if (ultraGrid.DisplayLayout.Override.AllowUpdate != DefaultableBoolean.True)
            //{
            //    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].CellActivation = Activation.NoEdit;
            //}
            //else if (!editable)
            //{
            //    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].CellActivation = Activation.NoEdit;
            //}
            //else
            //{
            //    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].CellActivation = Activation.AllowEdit;
            //}

            //SetUserDataGrid(ultraGrid, columnName, colNotNullable, colDataType, Infragistics.Win.HAlign.Center, caption, columnWidth, 0, "", "", "", "", "");

        }

        public void SetUserDataGrid(UltraGrid ultraGrid, string columnName, bool colNotNullable, GridColDataType_emu colDataType, HAlign HAlign, string caption, int columnWidth, int maxLength, string formatString, string editMask, string maxValue, string minValue, string regexPattern)
        {
            if (formatString == null)
                formatString = "";
            if (editMask == null)
                editMask = "";
            if (maxValue == null)
                maxValue = "";
            if (minValue == null)
                minValue = "";
            switch (colDataType)
            {
                case GridColDataType_emu.DateTime24:
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].DataType = typeof(DateTime);
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Style = Infragistics.Win.UltraWinGrid.ColumnStyle.DateTime;
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaskInput = "yyyy-mm-dd hh:mm:ss";
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Format = "yyyy-MM-dd HH:mm:ss";
                    if (formatString != "")
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Format = formatString;
                    }
                    if (editMask != "")
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaskInput = editMask;
                    }
                    break;

                case GridColDataType_emu.DateTime:
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].DataType = typeof(DateTime);
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Style = Infragistics.Win.UltraWinGrid.ColumnStyle.DateTime;
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaskInput = "yyyy-mm-dd hh:mm:ss";
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Format = "yyyy-MM-dd tt hh:mm:ss";
                    if (formatString != "")
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Format = formatString;
                    }
                    if (editMask != "")
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaskInput = editMask;
                    }
                    break;

                case GridColDataType_emu.YearMonthDay:
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].DataType = typeof(DateTime);
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Style = Infragistics.Win.UltraWinGrid.ColumnStyle.Date;
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaskInput = "yyyy-mm-dd";
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Format = "d";
                    if (formatString != "")
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Format = formatString;
                    }
                    if (maxLength != -1)
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaxLength = maxLength;
                    }
                    if (editMask != "")
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaskInput = editMask;
                    }
                    break;

                case GridColDataType_emu.YearMonth:
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].DataType = typeof(DateTime);
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Style = Infragistics.Win.UltraWinGrid.ColumnStyle.Date;
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaskInput = "yyyy-mm";
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Format = "yyyy-MM";
                    if (formatString != "")
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Format = formatString;
                    }
                    if (maxLength != -1)
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaxLength = maxLength;
                    }
                    if (editMask != "")
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaskInput = editMask;
                    }
                    break;

                case GridColDataType_emu.Year:
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].DataType = typeof(short);
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Style = Infragistics.Win.UltraWinGrid.ColumnStyle.Integer;
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaskInput = "nnnn";
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Format = "yyyy";
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaxLength = 4;
                    if (formatString != "")
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Format = formatString;
                    }
                    if (maxLength != -1)
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaxLength = maxLength;
                    }
                    if (editMask != "")
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaskInput = editMask;
                    }
                    break;

                case GridColDataType_emu.VarChar:
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].DataType = typeof(string);
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Style = Infragistics.Win.UltraWinGrid.ColumnStyle.Default;
                    if (formatString != "")
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Format = formatString;
                    }
                    if (maxLength != -1)
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaxLength = maxLength;
                    }
                    if (editMask != "")
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaskInput = editMask;
                    }
                    break;

                case GridColDataType_emu.Currency:
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].DataType = typeof(decimal);
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Style = Infragistics.Win.UltraWinGrid.ColumnStyle.Currency;
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Format = "c";
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaskInput = "-n,nnn,nnn,nnn,nnn,nnn,nnn,nnn,nnn,nnn";
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaxLength = 0x1d;
                    if (formatString != "")
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Format = formatString;
                    }
                    if (maxLength != -1)
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaxLength = maxLength;
                    }
                    if (editMask != "")
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaskInput = editMask;
                    }
                    if (maxValue != "")
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaxValue = maxValue;
                    }
                    if (minValue != "")
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MinValue = minValue;
                    }
                    break;

                case GridColDataType_emu.CurrencyNonNegative:
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].DataType = typeof(decimal);
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Style = Infragistics.Win.UltraWinGrid.ColumnStyle.CurrencyNonNegative;
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Format = "c";
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaskInput = "n,nnn,nnn,nnn,nnn,nnn,nnn,nnn,nnn,nnn";
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaxLength = 0x1d;
                    if (formatString != "")
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Format = formatString;
                    }
                    if (maxLength != -1)
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaxLength = maxLength;
                    }
                    if (editMask != "")
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaskInput = editMask;
                    }
                    if (maxValue != "")
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaxValue = maxValue;
                    }
                    if (minValue != "")
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MinValue = minValue;
                    }
                    break;

                case GridColDataType_emu.CurrencyPositive:
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].DataType = typeof(decimal);
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Style = Infragistics.Win.UltraWinGrid.ColumnStyle.CurrencyPositive;
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Format = "c";
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaskInput = "n,nnn,nnn,nnn,nnn,nnn,nnn,nnn,nnn,nnn";
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaxLength = 0x1d;
                    if (formatString != "")
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Format = formatString;
                    }
                    if (maxLength != -1)
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaxLength = maxLength;
                    }
                    if (editMask != "")
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaskInput = editMask;
                    }
                    if (maxValue != "")
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaxValue = maxValue;
                    }
                    if (minValue != "")
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MinValue = minValue;
                    }
                    break;
                case GridColDataType_emu.Double2: 
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].DataType = typeof(double);
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Style = Infragistics.Win.UltraWinGrid.ColumnStyle.Double;
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaskInput = "-n,nnn,nnn,nnn,nnn,nnn,nnn,nnn,nnn,nnn.nnn";
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaxLength = 0x1d;
                    if (formatString != "")
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Format = formatString;
                    }
                    if (maxLength != -1)
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaxLength = maxLength;
                    }
                    if (editMask != "")
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaskInput = editMask;
                    }
                    if (maxValue != "")
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaxValue = maxValue;
                    }
                    if (minValue != "")
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MinValue = minValue;
                    }
                    break;
                case GridColDataType_emu.Double:
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].DataType = typeof(double);
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Style = Infragistics.Win.UltraWinGrid.ColumnStyle.Double;
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaskInput = "-n,nnn,nnn,nnn,nnn,nnn,nnn,nnn,nnn,nnn";
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaxLength = 0x1d;
                    if (formatString != "")
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Format = formatString;
                    }
                    if (maxLength != -1)
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaxLength = maxLength;
                    }
                    if (editMask != "")
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaskInput = editMask;
                    }
                    if (maxValue != "")
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaxValue = maxValue;
                    }
                    if (minValue != "")
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MinValue = minValue;
                    }
                    break;

                case GridColDataType_emu.DoubleNonNegative:
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].DataType = typeof(double);
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Style = Infragistics.Win.UltraWinGrid.ColumnStyle.DoubleNonNegative;
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaskInput = "n,nnn,nnn,nnn,nnn,nnn,nnn,nnn,nnn,nnn";
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaxLength = 0x1d;
                    if (formatString != "")
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Format = formatString;
                    }
                    if (maxLength != -1)
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaxLength = maxLength;
                    }
                    if (editMask != "")
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaskInput = editMask;
                    }
                    if (maxValue != "")
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaxValue = maxValue;
                    }
                    if (minValue != "")
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MinValue = minValue;
                    }
                    break;

                case GridColDataType_emu.DoublePositive:
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].DataType = typeof(double);
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Style = Infragistics.Win.UltraWinGrid.ColumnStyle.DoublePositive;
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaskInput = "n,nnn,nnn,nnn,nnn,nnn,nnn,nnn,nnn,nnn";
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaxLength = 0x1d;
                    if (formatString != "")
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Format = formatString;
                    }
                    if (maxLength != -1)
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaxLength = maxLength;
                    }
                    if (editMask != "")
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaskInput = editMask;
                    }
                    if (maxValue != "")
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaxValue = maxValue;
                    }
                    if (minValue != "")
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MinValue = minValue;
                    }
                    break;

                case GridColDataType_emu.Integer:
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].DataType = typeof(int);
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Style = Infragistics.Win.UltraWinGrid.ColumnStyle.Integer;
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaskInput = "-n,nnn,nnn,nnn,nnn,nnn,nnn,nnn,nnn,nnn";
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaxLength = 0x1d;
                    if (formatString != "")
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Format = formatString;
                    }
                    if (maxLength != -1)
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaxLength = maxLength;
                    }
                    if (editMask != "")
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaskInput = editMask;
                    }
                    if (maxValue != "")
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaxValue = maxValue;
                    }
                    if (minValue != "")
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MinValue = minValue;
                    }
                    break;

                case GridColDataType_emu.IntegerNonNegative:
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].DataType = typeof(int);
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Style = Infragistics.Win.UltraWinGrid.ColumnStyle.IntegerNonNegative;
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaskInput = "n,nnn,nnn,nnn,nnn,nnn,nnn,nnn,nnn,nnn";
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaxLength = 0x1d;
                    if (formatString != "")
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Format = formatString;
                    }
                    if (maxLength != -1)
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaxLength = maxLength;
                    }
                    if (editMask != "")
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaskInput = editMask;
                    }
                    if (maxValue != "")
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaxValue = maxValue;
                    }
                    if (minValue != "")
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MinValue = minValue;
                    }
                    break;

                case GridColDataType_emu.IntegerPositive:
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].DataType = typeof(int);
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Style = Infragistics.Win.UltraWinGrid.ColumnStyle.IntegerPositive;
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaskInput = "n,nnn,nnn,nnn,nnn,nnn,nnn,nnn,nnn,nnn";
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaxLength = 0x1d;
                    if (formatString != "")
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Format = formatString;
                    }
                    if (maxLength != -1)
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaxLength = maxLength;
                    }
                    if (editMask != "")
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaskInput = editMask;
                    }
                    if (maxValue != "")
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaxValue = maxValue;
                    }
                    if (minValue != "")
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MinValue = minValue;
                    }
                    break;

                case GridColDataType_emu.CheckBox:
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].DataType = typeof(bool);
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Style = Infragistics.Win.UltraWinGrid.ColumnStyle.CheckBox;
                        UltraGridColumn column = ultraGrid.DisplayLayout.Bands[0].Columns[columnName];
                        column.Header.CheckBoxVisibility = HeaderCheckBoxVisibility.WhenUsingCheckEditor;
                        break;
                    }
                case GridColDataType_emu.Image:
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].DataType = typeof(Bitmap);
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Style = Infragistics.Win.UltraWinGrid.ColumnStyle.Image;
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].DataType = typeof(byte[]);
                    break;

                case GridColDataType_emu.Button:
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].DataType = typeof(string);
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Style = Infragistics.Win.UltraWinGrid.ColumnStyle.Button;
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].ButtonDisplayStyle = Infragistics.Win.UltraWinGrid.ButtonDisplayStyle.Always;
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].CellAppearance.TextHAlign = HAlign.Center;
                    break;

                case GridColDataType_emu.Color:
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].DataType = typeof(Color);
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Style = Infragistics.Win.UltraWinGrid.ColumnStyle.Color;
                    break;

                case GridColDataType_emu.Font:
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].DataType = typeof(string);
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Style = Infragistics.Win.UltraWinGrid.ColumnStyle.Font;
                    break;

                case GridColDataType_emu.TimeWithSpin:
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].DataType = typeof(DateTime);
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Style = Infragistics.Win.UltraWinGrid.ColumnStyle.TimeWithSpin;
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaskInput = "hh:mm:ss";
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Format = "tt hh:mm:ss";
                    if (formatString != "")
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Format = formatString;
                    }
                    if (maxLength != -1)
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaxLength = maxLength;
                    }
                    if (editMask != "")
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaskInput = editMask;
                    }
                    break;

                case GridColDataType_emu.Time24WithSpin:
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].DataType = typeof(DateTime);
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Style = Infragistics.Win.UltraWinGrid.ColumnStyle.TimeWithSpin;
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaskInput = "hh:mm:ss";
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Format = "HH:mm:ss";
                    if (formatString != "")
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Format = formatString;
                    }
                    if (maxLength != -1)
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaxLength = maxLength;
                    }
                    if (editMask != "")
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaskInput = editMask;
                    }
                    break;

                case GridColDataType_emu.URL:
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].DataType = typeof(string);
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Style = Infragistics.Win.UltraWinGrid.ColumnStyle.URL;
                    break;

                case GridColDataType_emu.TrackBar:
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].DataType = typeof(int);
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Style = Infragistics.Win.UltraWinGrid.ColumnStyle.TrackBar;
                    break;

                case GridColDataType_emu.Phone:
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].DataType = typeof(string);
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Style = Infragistics.Win.UltraWinGrid.ColumnStyle.Default;
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaskInput = "(###) ###-####";
                    if (formatString != "")
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Format = formatString;
                    }
                    if (editMask != "")
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaskInput = editMask;
                    }
                    break;

                case GridColDataType_emu.HandPhone:
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].DataType = typeof(string);
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Style = Infragistics.Win.UltraWinGrid.ColumnStyle.Default;
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaskInput = "###-####-####";
                    if (formatString != "")
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Format = formatString;
                    }
                    if (editMask != "")
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaskInput = editMask;
                    }
                    break;

                case GridColDataType_emu.IPv4Address:
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].DataType = typeof(string);
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Style = Infragistics.Win.UltraWinGrid.ColumnStyle.Default;
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaskInput = @"nnn\.nnn\.nnn\.nnn";
                    if (formatString != "")
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Format = formatString;
                    }
                    if (editMask != "")
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].MaskInput = editMask;
                    }
                    break;

                case GridColDataType_emu.Explain:
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].DataType = typeof(string);
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Style = Infragistics.Win.UltraWinGrid.ColumnStyle.Default;
                    break;
            }
            if (columnWidth != -1)
            {
                if (columnWidth == 0)
                {
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Hidden = true;
                }
                else
                {
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Width = columnWidth;
                }
            }
            switch (HAlign)
            {
                case HAlign.Left:
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Header.Appearance.TextHAlign = HAlign.Center;
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].CellAppearance.TextHAlign = HAlign.Left;
                    break;

                case HAlign.Center:
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Header.Appearance.TextHAlign = HAlign.Center;
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].CellAppearance.TextHAlign = HAlign.Center;
                    break;

                case HAlign.Right:
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Header.Appearance.TextHAlign = HAlign.Center;
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].CellAppearance.TextHAlign = HAlign.Right;
                    break;

                default:
                    ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Header.Appearance.TextHAlign = HAlign.Center;
                    break;
            }
            string str = string.Concat(new object[] { columnName, "|", colNotNullable ? "NN" : "", "|", colDataType.ToString(), "|", maxLength, "|", maxValue, "|", minValue, "|", caption, "|", columnWidth.ToString() });
            ultraGrid.DisplayLayout.Bands[bandIndex].Columns[columnName].Tag = str;
        }

        // Child Tree Column 설정
        public void InitColumnUltraTreeGrid(UltraGrid ultraGrid, string columnName, string caption, int bandIdx, bool visible, bool editable, int columnWidth, HAlign dataAlign)
        {
            if (ultraGrid.DisplayLayout.Bands.Count <= bandIdx)
            {
                throw new Exception(Common.getLangText("bandIdx는 bandCount보다 같거나 클 수 없습니다"));
            }
            if (ultraGrid.DisplayLayout.Bands[bandIdx].Columns[columnName] == null)
            {
                throw new Exception(Common.getLangText("존재하지 않는 컬럼명입니다"));
            }

            ultraGrid.DisplayLayout.Bands[bandIdx].Columns[columnName].Header.Caption = caption;
            ultraGrid.DisplayLayout.Bands[bandIdx].Columns[columnName].Header.Appearance.TextHAlign = HAlign.Center;
            ultraGrid.DisplayLayout.Bands[bandIdx].Columns[columnName].Hidden = !visible;

            if (editable)
            {
                ultraGrid.DisplayLayout.Bands[bandIdx].Columns[columnName].CellActivation = Activation.AllowEdit;
            }
            else
            {
                ultraGrid.DisplayLayout.Bands[bandIdx].Columns[columnName].CellActivation = Activation.NoEdit;
            }

            if (columnWidth != -1)
            {
                if (columnWidth == 0)
                {
                    ultraGrid.DisplayLayout.Bands[bandIdx].Columns[columnName].Hidden = true;
                }
                else
                {
                    ultraGrid.DisplayLayout.Bands[bandIdx].Columns[columnName].Width = columnWidth;
                }
            }
            ultraGrid.DisplayLayout.Bands[bandIdx].Columns[columnName].CellAppearance.TextHAlign = dataAlign;
        }


        public void SetColumnTextHAlign(UltraGrid ultraGrid, string columnName, HAlign hAlign)
        {
            string[] strArray = columnName.Split(new char[] { ',' });
            string key = "";
            if (strArray.Length > 0)
            {
                foreach (UltraGridBand band in ultraGrid.DisplayLayout.Bands)
                {
                    for (int i = 0; i < strArray.Length; i++)
                    {
                        key = strArray[i].ToString();
                        if (band.Columns.Exists(key))
                        {
                            band.Columns[key].CellAppearance.TextHAlign = hAlign;
                        }
                    }
                }
            }
        }

        public void SetInitUltraGridBind(UltraGrid ultraGrid)
        {
          
            DataTable table = new DataTable("temptable");
            for (int i = 0; i < ultraGrid.DisplayLayout.Bands[bandIndex].Columns.Count; i++)
            {
                table.Columns.Add(ultraGrid.DisplayLayout.Bands[bandIndex].Columns[i].Key.ToString());
            }
            ultraGrid.DataSource = table;
            //ultraGrid.DataBind();
            SetGridDataCopy(ultraGrid);
            
            //2020 01 31 HJH
            //ultraGrid.DisplayLayout.Override.DefaultRowHeight = 30;

            try
            {
                MethodInfo mi = (((System.Object)ultraGrid).GetType()).GetMethod("setUserColumn");
                mi.Invoke(ultraGrid, null);
            }
            catch { }
            
        }

        public static void SetGridDataCopy(UltraGrid ultraGrid)
        {
            ultraGrid.DisplayLayout.Override.AllowMultiCellOperations
                = ((AllowMultiCellOperation)(((((AllowMultiCellOperation.Copy) | AllowMultiCellOperation.Cut) | AllowMultiCellOperation.Paste))));
        }

        public void ExportExcel(UltraGrid ultraGrid)
        {
            UltraGridExcelExporter ExcelExporter = new UltraGridExcelExporter();

            SaveFileDialog saveFileDialog = new SaveFileDialog();
            saveFileDialog.InitialDirectory = "c:\\";
            saveFileDialog.Filter = "Excel Files (*.xls)|*.xls";
            saveFileDialog.FilterIndex = 2;
            saveFileDialog.RestoreDirectory = true;

            if (saveFileDialog.ShowDialog() == DialogResult.OK)
            {
                ExcelExporter.Export(ultraGrid, saveFileDialog.FileName);
            }
        }

        public void ColumnHeaderGroup(UltraGrid ultraGrid, string groupKey, string groupCaption, string columnNames)
        {
            if (!ultraGrid.DisplayLayout.Bands[bandIndex].Groups.Exists(groupKey))
            {
                ultraGrid.DisplayLayout.Bands[bandIndex].Groups.Add(groupKey, groupCaption);
            }
            ultraGrid.DisplayLayout.Bands[bandIndex].Groups[groupKey].Header.Appearance.TextHAlign = HAlign.Center;
            ultraGrid.DisplayLayout.Bands[bandIndex].GroupHeadersVisible = true;
            string[] strArray = columnNames.Split(new char[] { ',' });
            if (strArray.Length > 0)
            {
                for (int i = 0; i < strArray.Length; i++)
                {
                    string key = strArray[i].Trim();
                    if (((key != "") && (key != null)) && ultraGrid.DisplayLayout.Bands[bandIndex].Columns.Exists(key))
                    {
                        ultraGrid.DisplayLayout.Bands[bandIndex].Groups[groupKey].Columns.Add(ultraGrid.DisplayLayout.Bands[bandIndex].Columns[key]);
                    }
                }
            }
        }

        public void SetColumnMerge(Form form, UltraGrid ultraGrid, string columnName)
        {
            ultraGrid.DisplayLayout.Override.MergedCellStyle = MergedCellStyle.Always;
            ultraGrid.DisplayLayout.Override.MergedCellContentArea = MergedCellContentArea.VisibleRect;
            ultraGrid.DisplayLayout.Override.HeaderClickAction = HeaderClickAction.SortMulti;
            ultraGrid.DisplayLayout.Override.MergedCellAppearance.BackColor = Color.LightYellow;
            
            string[] strArray = columnName.Split(new char[] { ',' });
            string key = "";
            
            if (strArray.Length > 0)
            {
                for (int i = 0; i < strArray.Length; i++)
                {
                    key = strArray[i].ToString();
                    foreach (UltraGridBand band in ultraGrid.DisplayLayout.Bands)
                    {
                        if (band.Columns.Exists(key))
                        {
                            band.Columns[key].MergedCellStyle = MergedCellStyle.Always;
                        }
                    }
                }
            }
        }

        public static DataColumnCollection GetColumns(Form form, DataTable dtData)
        {
            return dtData.Columns;
        }

        #region 그리드 선택 로우의 다음에 추가
        /// <summary>
        /// 그리드 신규 Row 추가
        /// </summary>
        /// <param name="ultraGrid">그리드</param>
        /// <param name="dtTable">DataTable</param>
        /// <returns></returns>
        //public int AddRow(UltraGrid ultraGrid, DataTable dtTable = null, bool bNewLine = false)
        //{
        //     int iTbCnt = 0;
        //    if (dtTable == null)
        //    {
        //        //  MessageBox.Show(Common.getLangText("그리드의 DataSource 가 생성되지 않았습니다."), Common.getLangText("데이타소스"), MessageBoxButtons.OK, MessageBoxIcon.Asterisk);
        //        //  return -1;
        //        if (ultraGrid.DataSource.GetType().Name.ToUpper() == "DATATABLE")
        //        {
        //            dtTable = (DataTable)(ultraGrid.DataSource);
        //        }
        //        else
        //        {
        //            iTbCnt = ((DataSet)ultraGrid.DataSource).Tables.Count - 1;
        //            dtTable = ((DataSet)ultraGrid.DataSource).Tables[iTbCnt];
        //        }

        //    }

        //    int baseRow = 0;
        //    int baseRowDT = 0;

        //    if (bNewLine)
        //    {
        //        baseRow = ultraGrid.Rows.Count;
        //    }
        //    else
        //    {
        //        if (ultraGrid.ActiveRow == null || ultraGrid.Rows.Count == 0)
        //        {
        //            baseRow = 0;
        //            baseRowDT = 0;
        //        }
        //        else
        //        {
        //            baseRow = ultraGrid.ActiveRow.Index + 1;
        //            if (iTbCnt == 0)
        //                baseRowDT = baseRow;
        //            else
        //            {
        //                DataRow pdr = (ultraGrid.ActiveRow.ListObject as DataRowView).Row;
        //                for (int i = 0; i < dtTable.Rows.Count; i++)
        //                {
        //                    if (dtTable.Rows[i] == pdr)
        //                    {
        //                        baseRowDT = i + 1;
        //                        break;
        //                    }
        //                }

        //            }
        //        }
        //    }

        //    //ultraGrid.BeginUpdate();
        //    //UltraGridRow firstRow = ultraGrid.ActiveRowScrollRegion.FirstRow;
        //    //UltraGridRow dr = ultraGrid.DisplayLayout.Bands[0].AddNew();

        //    //ultraGrid.DisplayLayout.Rows.Move(dr, baseRow);
        //    //ultraGrid.ActiveRowScrollRegion.FirstRow = firstRow == null ? ultraGrid.Rows[0] : firstRow;

        //    //ultraGrid.EndUpdate();
        //    // ultraGrid.DisplayLayout.Bands[0].SortedColumns.Clear();

        //    DataRow Row = dtTable.NewRow();

        //    try
        //    {
        //        //System.Reflection.MethodInfo mi = (((System.Object)ultraGrid).GetType()).GetMethod("GetLastRow");
        //        //Row["rowSeq"] = mi.Invoke(ultraGrid, null);
        //        if (ultraGrid.ActiveRow != null)
        //        {
        //            System.Reflection.MethodInfo mi = (((System.Object)ultraGrid).GetType()).GetMethod("SetNewRow");
        //            mi.Invoke(ultraGrid, new Object[] { (Object)(ultraGrid.ActiveRow), (Object)(Row) });
        //        }
        //        dtTable.Rows.InsertAt(Row, baseRowDT);
        //        if (iTbCnt == 0)
        //        {
        //            foreach (UltraGridRow ugr in ultraGrid.Rows)
        //            {
        //                if ( (ugr.ListObject as DataRowView).Row== Row)
        //                {
        //                    ugr.Activate();
        //                   // ultraGrid.ActiveRow = ugr;
        //                    break;
        //                }
        //            }
        //           // ultraGrid.ActiveRow = ultraGrid.Rows[baseRow];
        //        }
        //        else
        //        {
        //            System.Reflection.MethodInfo mi = (((System.Object)ultraGrid).GetType()).GetMethod("GetUltraGridRow");
        //            ultraGrid.ActiveRow = (UltraGridRow)mi.Invoke(ultraGrid, new Object[] { (Object)(baseRowDT) });
        //            //for (int i =0;i< ultraGrid.Rows.Count ;i++ )
        //            //{
        //            //    if (Row["ROWSEQ"].ToString() == ultraGrid.Rows[i].Cells["ROWSEQ"].Value.ToString())
        //            //    {
        //            //        ultraGrid.ActiveRow = ultraGrid.Rows[i];
        //            //        break;
        //            //    }
        //            //}
        //        }
        //    }
        //    catch { }
        //    return baseRowDT;
        //}
        public int AddRow(UltraGrid ultraGrid, DataTable dtTable = null, bool bNewLine = false)
        {
            int iTbCnt = 0;
            if (dtTable == null)
            {
                //  MessageBox.Show(Common.getLangText("그리드의 DataSource 가 생성되지 않았습니다."), Common.getLangText("데이타소스"), MessageBoxButtons.OK, MessageBoxIcon.Asterisk);
                //  return -1;
                if (ultraGrid.DataSource.GetType().Name.ToUpper() == "DATATABLE")
                {
                    dtTable = (DataTable)(ultraGrid.DataSource);
                }
                else
                {
                    iTbCnt = ((DataSet)ultraGrid.DataSource).Tables.Count - 1;
                    dtTable = ((DataSet)ultraGrid.DataSource).Tables[iTbCnt];
                }

            }

            int baseRow = 0;
            int baseRowDT = 0;

            if (bNewLine)
            {
                baseRow = ultraGrid.Rows.Count;
            }
            else
            {
                if (ultraGrid.ActiveRow == null || ultraGrid.Rows.Count == 0)
                {
                    baseRow = 0;
                    baseRowDT = 0;
                }
                else
                {
                    baseRow = ultraGrid.ActiveRow.Index + 1;
                    if (iTbCnt == 0)
                        baseRowDT = baseRow;
                    else
                    {
                        string rowseq = ultraGrid.ActiveRow.Cells["ROWSEQ"].Value.ToString();

                        for (int i = 0; i < dtTable.Rows.Count; i++)
                        {
                            if (dtTable.Rows[i]["ROWSEQ"].ToString() == rowseq)
                            {
                                baseRowDT = i + 1;
                                break;
                            }
                        }

                    }
                }
            }

            //ultraGrid.BeginUpdate();
            //UltraGridRow firstRow = ultraGrid.ActiveRowScrollRegion.FirstRow;
            //UltraGridRow dr = ultraGrid.DisplayLayout.Bands[0].AddNew();

            //ultraGrid.DisplayLayout.Rows.Move(dr, baseRow);
            //ultraGrid.ActiveRowScrollRegion.FirstRow = firstRow == null ? ultraGrid.Rows[0] : firstRow;

            //ultraGrid.EndUpdate();
            // ultraGrid.DisplayLayout.Bands[0].SortedColumns.Clear();

            DataRow Row = dtTable.NewRow();

            try
            {
                System.Reflection.MethodInfo mi = (((System.Object)ultraGrid).GetType()).GetMethod("GetLastRow");
                Row["rowSeq"] = mi.Invoke(ultraGrid, null);
                if (ultraGrid.ActiveRow != null)
                {
                    mi = (((System.Object)ultraGrid).GetType()).GetMethod("SetNewRow");
                    mi.Invoke(ultraGrid, new Object[] { (Object)(ultraGrid.ActiveRow), (Object)(Row) });
                }
                dtTable.Rows.InsertAt(Row, baseRowDT);
                if (iTbCnt == 0)
                {
                    foreach (UltraGridRow ugr in ultraGrid.Rows)
                    {
                        if (ugr.Cells["rowSeq"].Value.ToString() == Row["rowSeq"].ToString())
                        {
                            ultraGrid.ActiveRow = ugr;
                            break;
                        }
                    }
                    // ultraGrid.ActiveRow = ultraGrid.Rows[baseRow];
                }
                else
                {
                    mi = (((System.Object)ultraGrid).GetType()).GetMethod("GetUltraGridRow");
                    ultraGrid.ActiveRow = (UltraGridRow)mi.Invoke(ultraGrid, new Object[] { (Object)(baseRowDT) });
                    //for (int i =0;i< ultraGrid.Rows.Count ;i++ )
                    //{
                    //    if (Row["ROWSEQ"].ToString() == ultraGrid.Rows[i].Cells["ROWSEQ"].Value.ToString())
                    //    {
                    //        ultraGrid.ActiveRow = ultraGrid.Rows[i];
                    //        break;
                    //    }
                    //}
                }
            }
            catch { }
            return baseRowDT;
        }
        #endregion

        #region 그리드 선택 row 삭제 표시
        /// <summary>
        /// 그리드 선택 ROW 삭제시 빨간색으로 표시
        /// </summary>
        /// <param name="form"></param>
        /// <param name="ultraGrid">그리드</param>
        /// <param name="dtTable">데이타 테이블</param>
        public static void DeleteCurrentRowGrid(Form form, UltraGrid ultraGrid, DataTable dtTable)
        {
            if (ultraGrid.ActiveRow != null)
                ultraGrid.ActiveRow.Appearance.BackColor = Color.Red;

            return;

            //---------------------------------------------------------------------
            // return 코드 아래는 "접근할 수 없는 코드가 있습니다." 경고가 발생하여 주석처리함.
            //---------------------------------------------------------------------
            //if ((ultraGrid.Rows.Count > 0) && (ultraGrid.ActiveRow != null))
            //{
            //    ultraGrid.EndUpdate();
            //    CurrencyManager manager = (CurrencyManager)form.BindingContext[ultraGrid.DataSource, ultraGrid.DataMember];
            //    manager.EndCurrentEdit();
            //    DataRowView view = null;
            //    int listIndex = -1;
            //    int index = ultraGrid.ActiveRow.Index;
            //    try
            //    {
            //        if (index >= 0)
            //        {
            //            listIndex = ultraGrid.Rows[index].ListIndex;
            //            if (listIndex >= 0)
            //            {
            //                view = (DataRowView)manager.List[listIndex];

            //                ultraGrid.ActiveRow.Appearance.BackColor = Color.Red;
            //            }
            //        }
            //    }
            //    catch (Exception exception)
            //    {
            //        MessageBox.Show(exception.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Hand);
            //        view.Row.RejectChanges();
            //    }
            //}
        }
        #endregion

        #region DataRowDelete
        /// <summary>
        /// 그리드 내 빨간색 Row 삭제
        /// </summary>
        /// <param name="ultraGrid">그리드</param>
        public static void DataRowDelete(UltraGrid ultraGrid)
        {
            for (int i = 0; i < ultraGrid.Rows.Count; i++)
            {
                if (ultraGrid.Rows[i].Appearance.BackColor == Color.Red)
                {
                    ultraGrid.Rows[i].Delete(false);
                    i--;
                }
            }
        }
        #endregion

        #region 그리드 로우 삭제
        /// <summary>
        /// 그리드 로우 삭제
        /// </summary>
        /// <param name="ultraGrid"></param>
        /// <param name="iRow"></param>
        public static void GridRowDelete(UltraGrid ultraGrid, int iRow)
        {
            ultraGrid.Rows[iRow].Delete(false);
        }
        #endregion

        #region 특정 컬럼 수정 모드로 변경
        /// <summary>
        /// 특정 컬럼 수정 모드로 변경
        /// </summary>
        /// <param name="ultraGrid">그리드</param>
        /// <param name="ColumnName">컬럼ID</param>
        /// <param name="RowNum">신규 생성 row</param>
        public static void ActivationAllowEdit(UltraGrid ultraGrid, string ColumnName, int dtRowNum = -1)
        {
            UltraGridRow ugr = null;
            if (dtRowNum == -1)
            {
                 ugr = ultraGrid.ActiveRow;
            }
            else
            {
                System.Reflection.MethodInfo mi = (((System.Object)ultraGrid).GetType()).GetMethod("GetUltraGridRow");
                 ugr = (UltraGridRow)mi.Invoke(ultraGrid, new Object[] { (Object)(dtRowNum) });
            }
            if (ugr != null)
            {
                ugr.Cells[ColumnName].IgnoreRowColActivation = true;
                ugr.Cells[ColumnName].Activation = Activation.AllowEdit;

            }
            //ultraGrid.Rows[RowNum].Cells[ColumnName].IgnoreRowColActivation = true;
            //ultraGrid.Rows[RowNum].Cells[ColumnName].Activation = Activation.AllowEdit;
        }
        #endregion

        #region 그리드 안에 콤보 바인딩.
        public static void SetComboUltraGrid(UltraGrid ultraGrid, string columnName, object dtInData, string valueFieldName, string displayFieldName)
        {

            ValueList list = ultraGrid.DisplayLayout.ValueLists.Add();
            DataTable table = (DataTable)dtInData;
            try
            {
                if (table.Rows.Count != 0)
                {
                    for (int i = 0; i < table.Rows.Count; i++)
                    {
                        list.ValueListItems.Add(table.Rows[i][valueFieldName].ToString(), table.Rows[i][displayFieldName].ToString());
                    }
                    foreach (UltraGridBand band in ultraGrid.DisplayLayout.Bands)
                    {
                        if (band.Columns.Exists(columnName))
                        {
                            ultraGrid.DisplayLayout.Bands[band.Index].Columns[columnName].ButtonDisplayStyle = Infragistics.Win.UltraWinGrid.ButtonDisplayStyle.OnRowActivate;
                            ultraGrid.DisplayLayout.Bands[band.Index].Columns[columnName].Style = Infragistics.Win.UltraWinGrid.ColumnStyle.DropDownList;
                            ultraGrid.DisplayLayout.Bands[band.Index].Columns[columnName].ValueList = list;
                        }
                    }
                }
            }
            catch (Exception)
            {
                MessageBox.Show(string.Format(Common.getLangText("{0}에 Combo 데이타 구성중 오류가 발생 하였습니다."), columnName), Common.getLangText("확인"), MessageBoxButtons.OK, MessageBoxIcon.Hand);
            }
        }

        public static void SetComboUltraGridSearch(UltraGrid ultraGrid, string columnName, object dtInData, string valueFieldName, string displayFieldName)
        {

            ValueList list = ultraGrid.DisplayLayout.ValueLists.Add();
            DataTable table = (DataTable)dtInData;
            try
            {
                if (table.Rows.Count != 0)
                {
                    for (int i = 0; i < table.Rows.Count; i++)
                    {
                        list.ValueListItems.Add(table.Rows[i][valueFieldName].ToString(), table.Rows[i][displayFieldName].ToString());
                    }
                    foreach (UltraGridBand band in ultraGrid.DisplayLayout.Bands)
                    {
                        if (band.Columns.Exists(columnName))
                        {
                            ultraGrid.DisplayLayout.Bands[band.Index].Columns[columnName].ButtonDisplayStyle = Infragistics.Win.UltraWinGrid.ButtonDisplayStyle.OnRowActivate;
                            ultraGrid.DisplayLayout.Bands[band.Index].Columns[columnName].ValueList = list;
                            ultraGrid.DisplayLayout.Bands[band.Index].Columns[columnName].Style = Infragistics.Win.UltraWinGrid.ColumnStyle.DropDown;
                            //2020 01 14 HJH
                            ultraGrid.DisplayLayout.Bands[band.Index].Columns[columnName].AutoCompleteMode = Infragistics.Win.AutoCompleteMode.SuggestAppend;
                            ultraGrid.DisplayLayout.Bands[band.Index].Columns[columnName].AutoSuggestFilterMode = Infragistics.Win.AutoSuggestFilterMode.Contains;

                        }
                    }
                }
            }
            catch (Exception)
            {
                MessageBox.Show(string.Format(Common.getLangText("{0}에 Combo 데이타 구성중 오류가 발생 하였습니다."), columnName), Common.getLangText("확인"), MessageBoxButtons.OK, MessageBoxIcon.Hand);
            }
        }
        #endregion

        //2020 01 09 HJH
        #region 그리드 안에 특정 셀 콤보 바인딩.
        public static void SetComboUltraGridCell(UltraGridCell ultraGridCell, string columnName, object dtInData, string valueFieldName, string displayFieldName)
        {
            ValueList list = new ValueList();
            DataTable table = (DataTable)dtInData;
            try
            {
                if (table.Rows.Count != 0)
                {
                    for (int i = 0; i < table.Rows.Count; i++)
                        list.ValueListItems.Add(table.Rows[i][valueFieldName].ToString(), table.Rows[i][displayFieldName].ToString());

                    ultraGridCell.Row.Cells[columnName].ValueList = list;
                }
                else
                    ultraGridCell.Row.Cells[columnName].ValueList = null;
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
                MessageBox.Show(string.Format(Common.getLangText("{0}에 Combo 데이타 구성중 오류가 발생 하였습니다."), columnName), Common.getLangText("확인"), MessageBoxButtons.OK, MessageBoxIcon.Hand);
            }
        }
        #endregion
        #region 그리드 안에 특정 셀 콤보 바인딩 + 검색.
        public static void SetComboUltraGridCellSearch(UltraGridCell ultraGridCell, string columnName, object dtInData, string valueFieldName, string displayFieldName)
        {
            ValueList list = new ValueList();
            DataTable table = (DataTable)dtInData;
            try
            {
                if (table.Rows.Count != 0)
                {
                    for (int i = 0; i < table.Rows.Count; i++)
                        list.ValueListItems.Add(table.Rows[i][valueFieldName].ToString(), table.Rows[i][displayFieldName].ToString());

                    ultraGridCell.Row.Cells[columnName].ValueList = list;
                    
                    ultraGridCell.Column.ButtonDisplayStyle = Infragistics.Win.UltraWinGrid.ButtonDisplayStyle.OnRowActivate;
                    ultraGridCell.Column.ValueList = list;
                    ultraGridCell.Column.Style = Infragistics.Win.UltraWinGrid.ColumnStyle.DropDown;
                    ultraGridCell.Column.AutoCompleteMode = Infragistics.Win.AutoCompleteMode.SuggestAppend;
                    ultraGridCell.Column.AutoSuggestFilterMode = Infragistics.Win.AutoSuggestFilterMode.Contains;

                }
                else
                    ultraGridCell.Row.Cells[columnName].ValueList = null;
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
                MessageBox.Show(string.Format(Common.getLangText("{0}에 Combo 데이타 구성중 오류가 발생 하였습니다."), columnName), Common.getLangText("확인"), MessageBoxButtons.OK, MessageBoxIcon.Hand);
            }
        }
        #endregion

        #region 변경된 그리드 데이터 체크
        public static bool CheckSearchDataGrid(Form form, UltraGrid ultraGrid, DataTable dtTable=null, bool messageDisplay=false)
        {
            bool flag = false;
            ultraGrid.EndUpdate();
            if (dtTable == null)
            {
                if (ultraGrid.DataSource.GetType().Name.ToUpper() == "DATATABLE")
                {
                    dtTable = (DataTable)(ultraGrid.DataSource);
                }
                else
                {
                    int iTbCnt = ((DataSet)ultraGrid.DataSource).Tables.Count - 1;
                    dtTable = ((DataSet)ultraGrid.DataSource).Tables[iTbCnt];
                }

            }
            RemoveGarbageRowsGrid(form, ultraGrid, dtTable);
            ((CurrencyManager)form.BindingContext[ultraGrid.DataSource, ultraGrid.DataMember]).EndCurrentEdit();
            DataTable changes = dtTable.GetChanges();
            flag = FindDeleteFlagRow(ultraGrid);
            if ((changes == null) && !flag)
            {
                //if (messageDisplay)
                //{
                //    MessageBox.Show("변경 된 데이타가 없습니다", "변경데이타 체크", MessageBoxButtons.OK, MessageBoxIcon.Asterisk);
                //}
                return false;
            }

            return true;
        }

        public static bool CheckSaveDataGrid(Form form, UltraGrid ultraGrid, DataTable dtTable=null, bool messageDisplay=true)
        {
            bool flag = false;
            ultraGrid.EndUpdate();
            if (dtTable == null)
            {
                if (ultraGrid.DataSource.GetType().Name.ToUpper() == "DATATABLE")
                {
                    dtTable = (DataTable)(ultraGrid.DataSource);
                }
                else
                {
                    int iTbCnt = ((DataSet)ultraGrid.DataSource).Tables.Count - 1;
                    dtTable = ((DataSet)ultraGrid.DataSource).Tables[iTbCnt];
                }

            }
   

            RemoveGarbageRowsGrid(form, ultraGrid, dtTable);
            ((CurrencyManager)form.BindingContext[ultraGrid.DataSource, ultraGrid.DataMember]).EndCurrentEdit();
            DataTable changes = dtTable.GetChanges();
            flag = FindDeleteFlagRow(ultraGrid);
            if ((changes == null) && !flag)
            {
                //if (messageDisplay)
                //{
                //    MessageBox.Show("변경 된 데이타가 없습니다", "변경데이타 체크", MessageBoxButtons.OK, MessageBoxIcon.Asterisk);
                //}
                return false;
            }
            if (!flag || (changes != null))
            {
                int num = -1;
                int num2 = -1;
                foreach (DataRow row in changes.Rows)
                {
                    num++;
                    if (row.RowState != DataRowState.Deleted)
                    {
                        foreach (DataColumn column in changes.Columns)
                        {
                            num2++;
                            object obj1 = row[column.ColumnName];
                            //if (((ultraGrid.DisplayLayout.Bands[bandIndex].Columns[column.ColumnName].Tag) != "") && !CheckNullGrid(ultraGrid, row, column))
                            if (((ultraGrid.DisplayLayout.Bands[bandIndex].Columns[column.ColumnName].Tag).ToString() != "") && !CheckNullGrid(ultraGrid, row, column))
                            {
                                ultraGrid.Rows[num].Selected = true;
                                ultraGrid.Rows[num].Cells[num2].Selected = true;
                                ultraGrid.Focus();
                                return false;
                            }
                            if (!CheckDataValidationGrid(ultraGrid, row, column))
                            {
                                ultraGrid.Rows[num].Selected = true;
                                ultraGrid.Rows[num].Cells[num2].Selected = true;
                                ultraGrid.Focus();
                                return false;
                            }
                        }
                        continue;
                    }
                }
            }
            return true;
        }

        public static void RemoveGarbageRowsGrid(Form form, UltraGrid ultraGrid, DataTable dtTable=null)
        {
            ultraGrid.EndUpdate();
            if (dtTable == null)
            {
                if (ultraGrid.DataSource.GetType().Name.ToUpper() == "DATATABLE")
                {
                    dtTable = (DataTable)(ultraGrid.DataSource);
                }
                else
                {
                    int iTbCnt = ((DataSet)ultraGrid.DataSource).Tables.Count - 1;
                    dtTable = ((DataSet)ultraGrid.DataSource).Tables[iTbCnt];
                }

            }
   
            ((CurrencyManager)form.BindingContext[ultraGrid.DataSource, ultraGrid.DataMember]).EndCurrentEdit();
            int listIndex = 0;
            for (int i = ultraGrid.Rows.Count - 1; i >= 0; i--)
            {
                listIndex = ultraGrid.Rows[i].ListIndex;
                if (((listIndex >= 0) && ((dtTable.Rows[listIndex].RowState == DataRowState.Detached))) && ((GetRowHeaderFlag(ultraGrid, i) == "") || (GetRowHeaderFlag(ultraGrid, i) == GridBase.RowHeaderFlag.MARK_DELETE)))
                //if (((listIndex >= 0) && ((dtTable.Rows[listIndex].RowState == DataRowState.Added) || (dtTable.Rows[listIndex].RowState == DataRowState.Detached))) && ((GetRowHeaderFlag(ultraGrid, i) == "") || (GetRowHeaderFlag(ultraGrid, i) == GridBase.RowHeaderFlag.MARK_DELETE)))
                {
                    dtTable.Rows[listIndex].Delete();
                }
            }
        }


        private static bool FindDeleteFlagRow(UltraGrid ultraGrid)
        {
            int num = 0;
            for (int i = 0; i < ultraGrid.Rows.Count; i++)
            {
                if ((ultraGrid.Rows[i].Tag != null) && (ultraGrid.Rows[i].Tag.ToString() == GridBase.RowHeaderFlag.MARK_DELETE))
                {
                    num++;
                }
            }
            if (num == 0)
            {
                return false;
            }
            return true;
        }


        private static bool CheckNullGrid(UltraGrid ultraGrid, DataRow curRow, DataColumn curColumn)
        {

            //if (!GetUserDataNotNullString(ultraGrid.DisplayLayout.Bands[bandIndex].Columns[curColumn.ColumnName].Tag).ToString().ToUpper().Equals("NN") || ((!curRow[curColumn.ColumnName].Equals(null) && !curRow[curColumn.ColumnName].Equals(DBNull.Value)) && !curRow[curColumn.ColumnName].ToString().Equals("")))
            if (!GetUserDataNotNullString(ultraGrid.DisplayLayout.Bands[bandIndex].Columns[curColumn.ColumnName].Tag.ToString()).ToString().ToUpper().Equals("NN") || ((!curRow[curColumn.ColumnName].Equals(null) && !curRow[curColumn.ColumnName].Equals(DBNull.Value)) && !curRow[curColumn.ColumnName].ToString().Equals("")))
            {
                return true;
            }
            
            MessageBox.Show(string.Format(Common.getLangText("[ {0} ] 항목은 필수입력 항목 입니다."), ultraGrid.DisplayLayout.Bands[bandIndex].Columns[curColumn.ColumnName].Header.Caption), Common.getLangText("필수항목"), MessageBoxButtons.OK, MessageBoxIcon.Information);
            return false;
        }



        private static bool CheckDataValidationGrid(UltraGrid ultraGrid, DataRow curRow, DataColumn curColumn)
        {
            //string[] strArray = (ultraGrid.DisplayLayout.Bands[bandIndex].Columns[curColumn.ColumnName].Tag)).Split(new char[] { '|' });
            string[] strArray = (ultraGrid.DisplayLayout.Bands[bandIndex].Columns[curColumn.ColumnName].Tag.ToString()).Split(new char[] { '|' });
            string caption = curColumn.Caption;
            if (strArray.Length > 1)
            {
                object obj2 = curRow[curColumn.ColumnName];
                strArray[1].ToString().ToUpper();
                string str3 = strArray[2].ToUpper();
                int maxLength = int.Parse(strArray[3].ToString());
                object obj3 = strArray[4];
                object obj4 = strArray[5];
                switch (str3)
                {
                    case "DATE":
                        {
                            string date = ((DateTime)obj2).ToString("yyyyMMdd");
                            if (FnUtil.isDate(date))
                            {
                                if (!FnUtil.isDate(obj4.ToString()))
                                {
                                    MessageBox.Show(string.Format(Common.getLangText("설정된 최소값 [{0}] 이 올바른 날짜 형식이 아닙니다."),obj4), Common.getLangText("입력오류"), MessageBoxButtons.OK, MessageBoxIcon.Hand);
                                    return false;
                                }
                                if (!obj4.ToString().Equals("") && !FnUtil.CheckDateMinValue(date, obj4.ToString()))
                                {
                                    MessageBox.Show(string.Format(Common.getLangText("[{0}] 의 최소값은 [{1}] 이어야 합니다.\r\n☞입력값 [{2}]") ,caption, obj4.ToString(),date.ToString()) , Common.getLangText("입력오류"), MessageBoxButtons.OK, MessageBoxIcon.Hand);
                                    return false;
                                }
                                if (!FnUtil.isDate(obj3.ToString()))
                                {
                                    MessageBox.Show(string.Format(Common.getLangText("설정된 최대값 [{0}] 이 올바른 날짜 형식이 아닙니다."), obj3), Common.getLangText("입력오류"), MessageBoxButtons.OK, MessageBoxIcon.Hand);
                                    return false;
                                }
                                if (obj3.ToString().Equals("") || FnUtil.CheckDateMaxValue(date, obj3.ToString()))
                                {
                                    break;
                                }
                                MessageBox.Show(string.Format(Common.getLangText("[{0}] 의 최대값은 [{1}] 이어야 합니다.\r\n☞입력값 [{2}]"),caption,obj3.ToString(),date.ToString()), Common.getLangText("입력오류"), MessageBoxButtons.OK, MessageBoxIcon.Hand);
                                return false;
                            }
                            MessageBox.Show(string.Format(Common.getLangText("[{0}] 는 올바른 날짜 형식이 아닙니다.\r\n☞입력값 [{1}]"),caption,date.ToString()), Common.getLangText("입력오류"), MessageBoxButtons.OK, MessageBoxIcon.Hand);
                            return false;
                        }
                    case "YEARMONTH":
                        {
                            string str5 = ((DateTime)obj2).ToString("yyyyMM");
                            string str6 = ((DateTime)obj2).ToString("yyyyMM") + "01";
                            if (FnUtil.isDate(str6))
                            {
                                if (!FnUtil.isDate(obj4.ToString() + "01"))
                                {
                                    MessageBox.Show(string.Format(Common.getLangText("설정된 최소값 [{0}] 이 올바른 날짜 형식이 아닙니다."),obj4),Common.getLangText( "입력오류"), MessageBoxButtons.OK, MessageBoxIcon.Hand);
                                    return false;
                                }
                                if (!obj4.ToString().Equals("") && !FnUtil.CheckDateMinValue(str6, obj4.ToString()))
                                {
                                    MessageBox.Show(string.Format(Common.getLangText("[{0}] 의 최소값은 [{1}] 이어야 합니다.\r\n☞입력값 [{2}]"),caption,obj4.ToString(),str5.ToString()),Common.getLangText( "입력오류"), MessageBoxButtons.OK, MessageBoxIcon.Hand);
                                    return false;
                                }
                                if (!FnUtil.isDate(obj3.ToString() + "01"))
                                {
                                    MessageBox.Show(string.Format(Common.getLangText("설정된 최대값 [{0}] 이 올바른 날짜 형식이 아닙니다."),obj3), Common.getLangText("입력오류"), MessageBoxButtons.OK, MessageBoxIcon.Hand);
                                    return false;
                                }
                                if (obj3.ToString().Equals("") || FnUtil.CheckDateMaxValue(str6, obj3.ToString()))
                                {
                                    break;
                                }
                                MessageBox.Show(string.Format(Common.getLangText("[{0}] 의 최대값은 [{1}] 이어야 합니다.\r\n☞입력값 [{2}]"),caption,obj3.ToString(),str5.ToString()), Common.getLangText("입력오류"), MessageBoxButtons.OK, MessageBoxIcon.Hand);
                                return false;
                            }
                            MessageBox.Show(string.Format(Common.getLangText("[{0}] 는 올바른 날짜 형식이 아닙니다.\r\n☞입력값 [{1}]"),caption,str5.ToString()), Common.getLangText("입력오류"), MessageBoxButtons.OK, MessageBoxIcon.Hand);
                            return false;
                        }
                    case "YEAR":
                        {
                            string str7 = ((DateTime)obj2).ToString("yyyy");
                            string str8 = ((DateTime)obj2).ToString("yyyy") + "0101";
                            if (FnUtil.isDate(str8))
                            {
                                if (!FnUtil.isDate(obj4.ToString() + "0101"))
                                {
                                    MessageBox.Show(string.Format(Common.getLangText("설정된 최소값 [{0}] 이 올바른 날짜 형식이 아닙니다."),obj4 ), Common.getLangText("입력오류"), MessageBoxButtons.OK, MessageBoxIcon.Hand);
                                    return false;
                                }
                                if (!obj4.ToString().Equals("") && !FnUtil.CheckDateMinValue(str8, obj4.ToString()))
                                {
                                    MessageBox.Show(string.Format(Common.getLangText("[{0}] 의 최소값은 [{1}] 이어야 합니다.\r\n☞입력값 [{2}]"),caption,obj4.ToString(), str7.ToString()), Common.getLangText("입력오류"), MessageBoxButtons.OK, MessageBoxIcon.Hand);
                                    return false;
                                }
                                if (!FnUtil.isDate(obj3.ToString() + "0101"))
                                {
                                    MessageBox.Show(string.Format(Common.getLangText("설정된 최대값 [{0}] 이 올바른 날짜 형식이 아닙니다."),obj3), Common.getLangText("입력오류"), MessageBoxButtons.OK, MessageBoxIcon.Hand);
                                    return false;
                                }
                                if (obj3.ToString().Equals("") || FnUtil.CheckDateMaxValue(str8, obj3.ToString()))
                                {
                                    break;
                                }
                                MessageBox.Show(string.Format(Common.getLangText("[{0}] 의 최대값은 [{1}] 이어야 합니다.\r\n☞입력값 [{2}]"),caption,obj3.ToString(),str7.ToString()), Common.getLangText("입력오류"), MessageBoxButtons.OK, MessageBoxIcon.Hand);
                                return false;
                            }
                            MessageBox.Show(string.Format(Common.getLangText("[{0}] 는 올바른 날짜 형식이 아닙니다.\r\n☞입력값 [{1}]"),caption,str7.ToString()), Common.getLangText("입력오류"), MessageBoxButtons.OK, MessageBoxIcon.Hand);
                            return false;
                        }
                    case "VARCHAR":
                        if ((!(maxLength.ToString() != "") || (int.Parse(maxLength.ToString()) <= 0)) || FnUtil.ChekcStringMaxLength(obj2.ToString(), maxLength))
                        {
                            break;
                        }
                        MessageBox.Show(string.Format(Common.getLangText("[{0}]의 데이터 길이는 {1}를 초과할 수 없습니다.\r\n☞입력값 [{2}]"),curColumn.Caption, maxLength.ToString(),obj2.ToString()), Common.getLangText("입력오류"), MessageBoxButtons.OK, MessageBoxIcon.Hand);
                        return false;

                    case "NUMBER":
                        if (FnUtil.isInt(obj2.ToString()))
                        {
                            if (((maxLength.ToString() != "") && (int.Parse(maxLength.ToString()) > 0)) && !FnUtil.ChekcStringMaxLength(obj2.ToString(), maxLength))
                            {
                                MessageBox.Show(string.Format(Common.getLangText("[{0}]의 데이터 길이는 {1}를 초과할 수 없습니다.\r\n☞입력값 [{2}]"),curColumn.Caption, maxLength.ToString(), obj2.ToString() ), Common.getLangText("입력오류"), MessageBoxButtons.OK, MessageBoxIcon.Hand);
                                return false;
                            }
                            if ((obj4.ToString() != "") && !FnUtil.CheckDataMinValue(obj2.ToString(), obj4.ToString()))
                            {
                                MessageBox.Show(string.Format(Common.getLangText("[{0}]의 데이터는 {1}와 같거나 커야 합니다.\r\n☞입력값 [{2}]"),curColumn.Caption,obj4.ToString(),obj2.ToString()), Common.getLangText("입력오류"), MessageBoxButtons.OK, MessageBoxIcon.Hand);
                                return false;
                            }
                            if (!(obj3.ToString() != "") || FnUtil.CheckDataMaxValue(obj2.ToString(), obj3.ToString()))
                            {
                                break;
                            }
                            MessageBox.Show(string.Format(Common.getLangText("[{0}]의 데이터는{1}를 초과할 수 없습니다.\r\n☞입력값 [{2}]"),curColumn.Caption,obj3.ToString(),obj2.ToString() ), Common.getLangText("입력오류"), MessageBoxButtons.OK, MessageBoxIcon.Hand);
                            return false;
                        }
                        MessageBox.Show(string.Format(Common.getLangText("[{0}]의 데이터는 정수만을 허용합니다.\r\n☞입력값 [{1}]"),curColumn.Caption, obj2.ToString()), Common.getLangText("입력오류"), MessageBoxButtons.OK, MessageBoxIcon.Hand);
                        return false;

                    case "DECIMAL":
                        if (FnUtil.isDecimal(obj2.ToString()))
                        {
                            if (((maxLength.ToString() != "") && (int.Parse(maxLength.ToString()) > 0)) && !FnUtil.ChekcStringMaxLength(obj2.ToString(), maxLength))
                            {
                                MessageBox.Show(string.Format(Common.getLangText("[{0}]의 데이터 길이는 {1}를 초과할 수 없습니다.\r\n☞입력값 [{2}]"),curColumn.Caption,maxLength.ToString(),obj2.ToString()), Common.getLangText("입력오류"), MessageBoxButtons.OK, MessageBoxIcon.Hand);
                                return false;
                            }
                            if ((obj4.ToString() != "") && !FnUtil.CheckDataMinValue(obj2.ToString(), obj4.ToString()))
                            {
                                MessageBox.Show(string.Format(Common.getLangText("[{0}]의 데이터는 {1}와 같거나 커야 합니다.\r\n☞입력값 [{2}]"),curColumn.Caption,obj4.ToString(),obj2.ToString()), Common.getLangText("입력오류"), MessageBoxButtons.OK, MessageBoxIcon.Hand);
                                return false;
                            }
                            if ((obj3.ToString() != "") && !FnUtil.CheckDataMaxValue(obj2.ToString(), obj3.ToString()))
                            {
                                MessageBox.Show(string.Format(Common.getLangText("[{0}]의 데이터는 {1}를 초과할 수 없습니다.\r\n☞입력값 [{2}]"),curColumn.Caption,obj3.ToString(), obj2.ToString()), Common.getLangText("입력오류"), MessageBoxButtons.OK, MessageBoxIcon.Hand);
                                return false;
                            }
                            break;
                        }
                        MessageBox.Show(string.Format(Common.getLangText("[{0}]의 데이터는 Decimal 형식을 허용합니다.\r\n☞입력값 [{1}]"), curColumn.Caption, obj2.ToString()), Common.getLangText("입력오류"), MessageBoxButtons.OK, MessageBoxIcon.Hand);
                        return false;
                }
            }
            return true;
        }


        public static string GetRowHeaderFlag(UltraGrid ultraGrid, int rowIndex)
        {
            if (ultraGrid.Rows.Count > 0)
            {
                if (ultraGrid.ActiveRow == null)
                {
                    return "";
                }
                if ((ultraGrid.Rows[rowIndex].Tag != null) && !(ultraGrid.Rows[rowIndex].Tag.ToString() == ""))
                {
                    return ultraGrid.Rows[rowIndex].Tag.ToString();
                }
            }
            return "";
        }

        private static string GetUserDataNotNullString(string userData)
        {
            try
            {
                string[] strArray = userData.Split(new char[] { '|' });
                if (strArray.Length <= 0)
                {
                    return "";
                }
                return strArray[1].Trim();
            }
            catch(Exception ex)
            {
                Console.WriteLine(ex.Message);
                return "";
            }
        }

        public void ColumnHeaderVisible(UltraGrid ultraGrid, bool visible)
        {
            foreach (UltraGridBand band in ultraGrid.DisplayLayout.Bands)
            {
                if (band.Index > 0)
                {
                    band.ColHeadersVisible = visible;
                }
            }
        }

        #region 그리드 초기화
        public void Grid_Clear(UltraGrid gGrid)
        {
            DataTable dtTemp = null;

            dtTemp = (DataTable)gGrid.DataSource;
            if (dtTemp != null)
            {
                dtTemp.Clear();
            }

            gGrid.DataSource = dtTemp;
            gGrid.DataBind();
        }
        #endregion
        #endregion
    }

    public class UltraStyleUtil
    {
        private String AppPath = String.Empty;
        private String IslFile = String.Empty;

        public UltraStyleUtil(String Path, String File)
        {
            AppPath = Path;
            IslFile = File;
        }

        public String GetIsl()
        {
            return System.IO.Path.Combine(AppPath, IslFile);
        }
    }

    public enum GridColDataType_emu
    {
        DateTime24,
        DateTime,
        YearMonthDay,
        YearMonth,
        Year,
        VarChar,
        Currency,
        CurrencyNonNegative,
        CurrencyPositive,
        Double,
        DoubleNonNegative,
        DoublePositive,
        Integer,
        IntegerNonNegative,
        IntegerPositive,
        CheckBox,
        Image,
        Button,
        Color,
        Font,
        TimeWithSpin,
        Time24WithSpin,
        URL,
        TrackBar,
        Phone,
        HandPhone,
        IPv4Address,
        ProgressBar,
        FormattedText,
        Explain,
        Double2

    }
}
