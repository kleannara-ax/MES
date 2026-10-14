using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Configuration;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using Infragistics.Win;
using Infragistics.Win.UltraWinMaskedEdit;
using Microsoft.Practices.EnterpriseLibrary.Data;
using System.Data.Common;
using Infragistics.Win.UltraWinGrid;
using System.Data.SqlClient;
using Microsoft.Practices.EnterpriseLibrary.Common.Configuration;
using SAMMI;

namespace SmartDas.Components
{
    /// <summary>
    /// 
    /// </summary>
    [DefaultEvent("GridClick")]
    public partial class MESGrid : UserControl
    {
        Database db;
        DataSet ds;

        private DbCommand _select;
        private string _selectStr;
        private string _sHead;

        private MESButton UpButton;
        private MESButton DownButton;
        private MESButton_Top UpButton_Top;
        private MESButton_Top DownButton_Top;
        //private bool _bColSelect;

        private int _FixedCols;
        private int _CountRow;

        private UltraGridRow _row;
        private UltraGridColumn _column;

        DbDataAdapter da;

        /// <summary>
        /// MES-DAS 용 그리드.
        /// 
        /// Grid.SetStoreProc();
        /// Grid.ParameterList.Add(new SqlParameter("New Param1", SqlDbType.VarChar));
        /// Grid.ParameterList.Add(new SqlParameter("New Param2", SqlDbType.VarChar));
        /// Grid.ParameterList.Add(new SqlParameter("OUT_CURSOR", SqlDbType.RefCursor, ParameterDirection.Output));

        /// Grid.ParameterList["New Param1"].Value = "";
        /// Grid.ParameterList["New Param2"].Value = "ALL";

        /// Grid.DoFind();
        /// </summary>
        public MESGrid()
        {
            InitializeComponent();

            ds = new DataSet();
            Grid.DataSource = ds;
        }

        /// <summary>
        /// 연결된 데이터 테이블
        /// </summary>
        public DataTable DataSource
        {
            get
            {
                if (ds.Tables.Count >= 2)
                    return ds.Tables[1];
                else if (ds.Tables.Count == 1)
                    return ds.Tables[0];
                else
                    return null;
            }
            set { Grid.DataSource = value; }
        }

        public UltraGridLayout DisplayLayout
        {
            get { return Grid.DisplayLayout; }

        }

        public DataSet DataSourceDS
        {
            get
            {
                return ds;
            }
            set { ds = value; }
        }

        /// <summary>
        /// 헤더 정보 - 헤더 정보를 설정하면 조회 후 헤더 정보대로 정렬하거나 숨길 수 있다.
        /// 
        /// 예제 ) 코드@C^100|코드명@L^100
        /// 구조 ) 헤더명1@정렬코드1^넓이1|헤더명2@정렬코드2^넓이2|...
        ///        정렬코드 ( C : 중앙, L : 좌측 정렬, R : 우측 정렬, H : 숨김 )
        /// </summary>
        public string HeadString
        {
            get { return _sHead; }
            set { _sHead = value; }
        }

        public AutoFitStyle GridAutoFitStyle
        {
            get { return Grid.DisplayLayout.AutoFitStyle; }
            set { Grid.DisplayLayout.AutoFitStyle = value; }
        }


        public VAlign VAlign
        {
            get { return Grid.DisplayLayout.Appearance.TextVAlign; }
            set { Grid.DisplayLayout.Appearance.TextVAlign = value; }
        }

        public Infragistics.Win.UltraWinGrid.Scrollbars ScrollBar
        {
            get { return Grid.DisplayLayout.Scrollbars; }
            set { Grid.DisplayLayout.Scrollbars = value; }
        }


        #region Grid 병합
        /// <summary> 
        /// 지정한 그리드 컬럼의 그룹을 설정합니다.(*부분그룹병합)
        /// </summary>
        public void GridHeaderMerge(string GroupKey, string GroupCaption, int nFirst, int nLast, Infragistics.Win.HAlign AlignHeader = HAlign.Center)
        {
            UltraGridBand band = Grid.DisplayLayout.Bands[0];

            //Arrange the band's column in Group Layout style
            Grid.DisplayLayout.Bands[0].RowLayoutStyle = RowLayoutStyle.GroupLayout;

            //Enbale Column/Group moving
            //Grid.DisplayLayout.Override.AllowRowLayoutColMoving = Infragistics.Win.Layout.GridBagLayoutAllowMoving.AllowAll;

            for (int i = 0; i < band.Columns.BoundColumnsCount; i++)
            {
                if (i >= nFirst && i <= nLast)
                {
                    if (i == nFirst)
                    {
                        // 이미 같은 그룹키가 만들어져 있다면.
                        if (band.Columns.IndexOf(GroupKey) > 0)
                            return;

                        band.Columns.Add(GroupKey, GroupCaption);

                        band.Columns[GroupKey].RowLayoutColumnInfo.OriginX = i * 2;
                        band.Columns[GroupKey].RowLayoutColumnInfo.OriginY = 0;

                        band.Columns[GroupKey].RowLayoutColumnInfo.SpanX = (nLast - nFirst + 1) * 2;
                        band.Columns[GroupKey].RowLayoutColumnInfo.SpanY = 2;

                        band.Columns[GroupKey].RowLayoutColumnInfo.LabelPosition = LabelPosition.LabelOnly;
                        band.Columns[GroupKey].Header.Appearance.TextHAlign = AlignHeader;
                    }
                    band.Columns[i].RowLayoutColumnInfo.OriginX = i * 2;
                    band.Columns[i].RowLayoutColumnInfo.OriginY = 2;
                    band.Columns[i].Tag = GroupKey;

                    band.Columns[i].RowLayoutColumnInfo.SpanX = 2;
                    band.Columns[i].RowLayoutColumnInfo.SpanY = 2;
                }
                else
                {
                    if (band.Columns[i].Tag != null)
                    {
                        band.Columns[i].RowLayoutColumnInfo.OriginX = i * 2;
                        band.Columns[i].RowLayoutColumnInfo.OriginY = 2;

                        band.Columns[i].RowLayoutColumnInfo.SpanX = 2;
                        band.Columns[i].RowLayoutColumnInfo.SpanY = 2;
                    }
                    else
                    {
                        band.Columns[i].RowLayoutColumnInfo.OriginX = i * 2;
                        band.Columns[i].RowLayoutColumnInfo.OriginY = 0;

                        band.Columns[i].RowLayoutColumnInfo.SpanX = 2;
                        band.Columns[i].RowLayoutColumnInfo.SpanY = 4;
                    }
                }
            }
            GridHeaderMergeVertical(nFirst, nLast);
        }

        /// <summary>
        /// 그리드 헤드 2단 Vertical Merge기능
        /// </summary>
        /// <param name="Grid">적용 그리드</param>
        /// <param name="Columns">적용 컬럼명</param>
        /// <param name="nFirst">적용 컬럼의 Merge 하고자 하는 시작 위치</param>
        /// <param name="nLast">적용 컬럼의 Merge 하고자 하는 끝 위치</param>
        /// <param name="AlignHeader">Header Label Align</param>
        public void GridHeaderMergeVertical(int nFirst, int nLast, Infragistics.Win.HAlign AlignHeader = HAlign.Center)
        {
            UltraGridBand band = Grid.DisplayLayout.Bands[0];

            //Arrange the band's column in Group Layout style
            Grid.DisplayLayout.Bands[0].RowLayoutStyle = RowLayoutStyle.GroupLayout;

            //Enbale Column/Group moving
            //Grid.DisplayLayout.Override.AllowRowLayoutColMoving = Infragistics.Win.Layout.GridBagLayoutAllowMoving.AllowAll;

            for (int i = nFirst; i <= nLast; i++)
            {
                band.Columns[i].RowLayoutColumnInfo.OriginX = i * 2;
                band.Columns[i].RowLayoutColumnInfo.OriginY = 0;

                band.Columns[i].RowLayoutColumnInfo.SpanX = 2;
                band.Columns[i].RowLayoutColumnInfo.SpanY = 4;
                band.Columns[i].RowLayoutColumnInfo.LabelSpan = 4;
                band.Columns[i].Header.Appearance.TextHAlign = AlignHeader;
                band.Columns[i].Header.Appearance.TextVAlign = VAlign.Bottom;
            }
        }
        public void SetColumnMerge(string columnName)
        {
            Grid.DisplayLayout.Override.MergedCellStyle = MergedCellStyle.Always;
            Grid.DisplayLayout.Override.MergedCellContentArea = MergedCellContentArea.VisibleRect;
            Grid.DisplayLayout.Override.HeaderClickAction = HeaderClickAction.SortMulti;
            Grid.DisplayLayout.Override.MergedCellAppearance.BackColor = Color.LightYellow;

            string[] strArray = columnName.Split(new char[] { ',' });
            string key = "";

            if (strArray.Length > 0)
            {
                for (int i = 0; i < strArray.Length; i++)
                {
                    key = strArray[i].ToString();
                    foreach (UltraGridBand band in Grid.DisplayLayout.Bands)
                    {
                        if (band.Columns.Exists(key))
                        {
                            band.Columns[key].MergedCellStyle = MergedCellStyle.Always;
                        }
                    }
                }
            }
        }
        #endregion

        #region Grid 초기화
        public void InitColumnUltraGrid(UltraGrid ultraGrid, string columnName, string caption, bool colNotNullable, string colDataType)
        {
            if ((caption != null) && (caption != ""))
            {
                ultraGrid.DisplayLayout.Bands[0].Columns.Add(columnName, caption);
            }
            else
            {
                ultraGrid.DisplayLayout.Bands[0].Columns.Add(columnName, columnName);
            }
            ultraGrid.DisplayLayout.Bands[0].Columns[columnName].AutoSizeMode = ColumnAutoSizeMode.None;
            ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MergedCellStyle = MergedCellStyle.Never;
            ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaskClipMode = MaskMode.IncludeLiterals;
            ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaskDisplayMode = MaskMode.IncludeLiterals;
            ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaskDataMode = MaskMode.IncludeLiterals;


            SetUserDataGrid(ultraGrid, columnName, colNotNullable, colDataType, caption, 0, "", "", "", "", "");

        }

        public void SetUserDataGrid(UltraGrid ultraGrid, string columnName, bool colNotNullable, string colDataType, string caption, int maxLength, string formatString, string editMask, string maxValue, string minValue, string regexPattern)
        {
            switch (colDataType)
            {
                case "DateTime24":
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].DataType = typeof(DateTime);
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].Style = Infragistics.Win.UltraWinGrid.ColumnStyle.DateTime;
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaskInput = "yyyy-mm-dd hh:mm:ss";
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].Format = "yyyy-MM-dd HH:mm:ss";
                    if (formatString != "")
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].Format = formatString;
                    }
                    if (editMask != "")
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaskInput = editMask;
                    }
                    break;

                case "DateTime":
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].DataType = typeof(DateTime);
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].Style = Infragistics.Win.UltraWinGrid.ColumnStyle.DateTime;
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaskInput = "yyyy-mm-dd hh:mm:ss";
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].Format = "yyyy-MM-dd tt hh:mm:ss";
                    if (formatString != "")
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].Format = formatString;
                    }
                    if (editMask != "")
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaskInput = editMask;
                    }
                    break;

                case "YearMonthDay":
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].DataType = typeof(DateTime);
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].Style = Infragistics.Win.UltraWinGrid.ColumnStyle.Date;
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaskInput = "yyyy-mm-dd";
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].Format = "d";
                    if (formatString != "")
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].Format = formatString;
                    }
                    if (maxLength != -1)
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaxLength = maxLength;
                    }
                    if (editMask != "")
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaskInput = editMask;
                    }
                    break;

                case "YearMonth":
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].DataType = typeof(DateTime);
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].Style = Infragistics.Win.UltraWinGrid.ColumnStyle.Date;
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaskInput = "yyyy-mm";
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].Format = "yyyy-MM";
                    if (formatString != "")
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].Format = formatString;
                    }
                    if (maxLength != -1)
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaxLength = maxLength;
                    }
                    if (editMask != "")
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaskInput = editMask;
                    }
                    break;

                case "Year":
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].DataType = typeof(short);
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].Style = Infragistics.Win.UltraWinGrid.ColumnStyle.Integer;
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaskInput = "nnnn";
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].Format = "yyyy";
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaxLength = 4;
                    if (formatString != "")
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].Format = formatString;
                    }
                    if (maxLength != -1)
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaxLength = maxLength;
                    }
                    if (editMask != "")
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaskInput = editMask;
                    }
                    break;

                case "VarChar":
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].DataType = typeof(string);
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].Style = Infragistics.Win.UltraWinGrid.ColumnStyle.Default;
                    if (formatString != "")
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].Format = formatString;
                    }
                    if (maxLength != -1)
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaxLength = maxLength;
                    }
                    if (editMask != "")
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaskInput = editMask;
                    }
                    break;

                case "Currency":
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].DataType = typeof(decimal);
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].Style = Infragistics.Win.UltraWinGrid.ColumnStyle.Currency;
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].Format = "c";
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaskInput = "-n,nnn,nnn,nnn,nnn,nnn,nnn,nnn,nnn,nnn";
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaxLength = 0x1d;
                    if (formatString != "")
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].Format = formatString;
                    }
                    if (maxLength != -1)
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaxLength = maxLength;
                    }
                    if (editMask != "")
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaskInput = editMask;
                    }
                    if (maxValue != "")
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaxValue = maxValue;
                    }
                    if (minValue != "")
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MinValue = minValue;
                    }
                    break;

                case "CurrencyNonNegative":
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].DataType = typeof(decimal);
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].Style = Infragistics.Win.UltraWinGrid.ColumnStyle.CurrencyNonNegative;
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].Format = "c";
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaskInput = "n,nnn,nnn,nnn,nnn,nnn,nnn,nnn,nnn,nnn";
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaxLength = 0x1d;
                    if (formatString != "")
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].Format = formatString;
                    }
                    if (maxLength != -1)
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaxLength = maxLength;
                    }
                    if (editMask != "")
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaskInput = editMask;
                    }
                    if (maxValue != "")
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaxValue = maxValue;
                    }
                    if (minValue != "")
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MinValue = minValue;
                    }
                    break;

                case "CurrencyPositive":
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].DataType = typeof(decimal);
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].Style = Infragistics.Win.UltraWinGrid.ColumnStyle.CurrencyPositive;
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].Format = "c";
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaskInput = "n,nnn,nnn,nnn,nnn,nnn,nnn,nnn,nnn,nnn";
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaxLength = 0x1d;
                    if (formatString != "")
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].Format = formatString;
                    }
                    if (maxLength != -1)
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaxLength = maxLength;
                    }
                    if (editMask != "")
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaskInput = editMask;
                    }
                    if (maxValue != "")
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaxValue = maxValue;
                    }
                    if (minValue != "")
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MinValue = minValue;
                    }
                    break;

                case "Double":
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].DataType = typeof(double);
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].Style = Infragistics.Win.UltraWinGrid.ColumnStyle.Double;
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaskInput = "-n,nnn,nnn,nnn,nnn,nnn,nnn,nnn,nnn,nnn";
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaxLength = 0x1d;
                    if (formatString != "")
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].Format = formatString;
                    }
                    if (maxLength != -1)
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaxLength = maxLength;
                    }
                    if (editMask != "")
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaskInput = editMask;
                    }
                    if (maxValue != "")
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaxValue = maxValue;
                    }
                    if (minValue != "")
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MinValue = minValue;
                    }
                    break;

                case "DoubleNonNegative":
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].DataType = typeof(double);
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].Style = Infragistics.Win.UltraWinGrid.ColumnStyle.DoubleNonNegative;
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaskInput = "n,nnn,nnn,nnn,nnn,nnn,nnn,nnn,nnn,nnn";
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaxLength = 0x1d;
                    if (formatString != "")
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].Format = formatString;
                    }
                    if (maxLength != -1)
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaxLength = maxLength;
                    }
                    if (editMask != "")
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaskInput = editMask;
                    }
                    if (maxValue != "")
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaxValue = maxValue;
                    }
                    if (minValue != "")
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MinValue = minValue;
                    }
                    break;

                case "DoublePositive":
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].DataType = typeof(double);
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].Style = Infragistics.Win.UltraWinGrid.ColumnStyle.DoublePositive;
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaskInput = "n,nnn,nnn,nnn,nnn,nnn,nnn,nnn,nnn,nnn";
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaxLength = 0x1d;
                    if (formatString != "")
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].Format = formatString;
                    }
                    if (maxLength != -1)
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaxLength = maxLength;
                    }
                    if (editMask != "")
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaskInput = editMask;
                    }
                    if (maxValue != "")
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaxValue = maxValue;
                    }
                    if (minValue != "")
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MinValue = minValue;
                    }
                    break;

                case "Integer":
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].DataType = typeof(int);
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].Style = Infragistics.Win.UltraWinGrid.ColumnStyle.Integer;
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaskInput = "-n,nnn,nnn,nnn,nnn,nnn,nnn,nnn,nnn,nnn";
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaxLength = 0x1d;
                    if (formatString != "")
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].Format = formatString;
                    }
                    if (maxLength != -1)
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaxLength = maxLength;
                    }
                    if (editMask != "")
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaskInput = editMask;
                    }
                    if (maxValue != "")
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaxValue = maxValue;
                    }
                    if (minValue != "")
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MinValue = minValue;
                    }
                    break;

                case "IntegerNonNegative":
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].DataType = typeof(int);
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].Style = Infragistics.Win.UltraWinGrid.ColumnStyle.IntegerNonNegative;
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaskInput = "n,nnn,nnn,nnn,nnn,nnn,nnn,nnn,nnn,nnn";
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaxLength = 0x1d;
                    if (formatString != "")
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].Format = formatString;
                    }
                    if (maxLength != -1)
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaxLength = maxLength;
                    }
                    if (editMask != "")
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaskInput = editMask;
                    }
                    if (maxValue != "")
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaxValue = maxValue;
                    }
                    if (minValue != "")
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MinValue = minValue;
                    }
                    break;

                case "IntegerPositive":
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].DataType = typeof(int);
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].Style = Infragistics.Win.UltraWinGrid.ColumnStyle.IntegerPositive;
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaskInput = "n,nnn,nnn,nnn,nnn,nnn,nnn,nnn,nnn,nnn";
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaxLength = 0x1d;
                    if (formatString != "")
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].Format = formatString;
                    }
                    if (maxLength != -1)
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaxLength = maxLength;
                    }
                    if (editMask != "")
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaskInput = editMask;
                    }
                    if (maxValue != "")
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaxValue = maxValue;
                    }
                    if (minValue != "")
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MinValue = minValue;
                    }
                    break;

                case "CheckBox":
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].DataType = typeof(bool);
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].Style = Infragistics.Win.UltraWinGrid.ColumnStyle.CheckBox;
                        UltraGridColumn column = ultraGrid.DisplayLayout.Bands[0].Columns[columnName];
                        column.Header.CheckBoxVisibility = HeaderCheckBoxVisibility.WhenUsingCheckEditor;
                        break;
                    }
                case "CHECKBOX2":
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].DataType = typeof(bool);
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].Style = Infragistics.Win.UltraWinGrid.ColumnStyle.CheckBox;
                        UltraGridColumn column = ultraGrid.DisplayLayout.Bands[0].Columns[columnName];
                        break;
                    }
                case "Image":
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].DataType = typeof(Bitmap);
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].Style = Infragistics.Win.UltraWinGrid.ColumnStyle.Image;
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].DataType = typeof(byte[]);
                    break;

                case "Button":
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].DataType = typeof(string);
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].Style = Infragistics.Win.UltraWinGrid.ColumnStyle.Button;
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].ButtonDisplayStyle = Infragistics.Win.UltraWinGrid.ButtonDisplayStyle.Always;
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].CellButtonAppearance.BackColor = Color.Gold;
                    //ultraGrid.DisplayLayout.Bands[0].Columns[columnName].CellButtonAppearance.ImageBackground = global::SmartDas.Properties.Resources.기본버튼01;
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].CellButtonAppearance.ThemedElementAlpha = Alpha.Transparent;
                    //ultraGrid.DisplayLayout.Bands[0].Columns[columnName].CellButtonAppearance.ImageBackgroundStyle = ImageBackgroundStyle.Stretched;
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].CellAppearance.TextHAlign = HAlign.Center;
                    ultraGrid.CreationFilter = new CF();
                    break;

                case "Color":
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].DataType = typeof(Color);
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].Style = Infragistics.Win.UltraWinGrid.ColumnStyle.Color;
                    break;

                case "Font":
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].DataType = typeof(string);
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].Style = Infragistics.Win.UltraWinGrid.ColumnStyle.Font;
                    break;

                case "TimeWithSpin":
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].DataType = typeof(DateTime);
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].Style = Infragistics.Win.UltraWinGrid.ColumnStyle.TimeWithSpin;
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaskInput = "hh:mm:ss";
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].Format = "tt hh:mm:ss";
                    if (formatString != "")
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].Format = formatString;
                    }
                    if (maxLength != -1)
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaxLength = maxLength;
                    }
                    if (editMask != "")
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaskInput = editMask;
                    }
                    break;

                case "Time24WithSpin":
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].DataType = typeof(DateTime);
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].Style = Infragistics.Win.UltraWinGrid.ColumnStyle.TimeWithSpin;
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaskInput = "hh:mm:ss";
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].Format = "HH:mm:ss";
                    if (formatString != "")
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].Format = formatString;
                    }
                    if (maxLength != -1)
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaxLength = maxLength;
                    }
                    if (editMask != "")
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaskInput = editMask;
                    }
                    break;

                case "URL":
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].DataType = typeof(string);
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].Style = Infragistics.Win.UltraWinGrid.ColumnStyle.URL;
                    break;

                case "TrackBar":
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].DataType = typeof(int);
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].Style = Infragistics.Win.UltraWinGrid.ColumnStyle.TrackBar;
                    break;

                case "Phone":
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].DataType = typeof(string);
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].Style = Infragistics.Win.UltraWinGrid.ColumnStyle.Default;
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaskInput = "(###) ###-####";
                    if (formatString != "")
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].Format = formatString;
                    }
                    if (editMask != "")
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaskInput = editMask;
                    }
                    break;

                case "HandPhone":
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].DataType = typeof(string);
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].Style = Infragistics.Win.UltraWinGrid.ColumnStyle.Default;
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaskInput = "###-####-####";
                    if (formatString != "")
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].Format = formatString;
                    }
                    if (editMask != "")
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaskInput = editMask;
                    }
                    break;

                case "IPv4Address":
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].DataType = typeof(string);
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].Style = Infragistics.Win.UltraWinGrid.ColumnStyle.Default;
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaskInput = @"nnn\.nnn\.nnn\.nnn";
                    if (formatString != "")
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].Format = formatString;
                    }
                    if (editMask != "")
                    {
                        ultraGrid.DisplayLayout.Bands[0].Columns[columnName].MaskInput = editMask;
                    }
                    break;

                case "Explain":
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].DataType = typeof(string);
                    ultraGrid.DisplayLayout.Bands[0].Columns[columnName].Style = Infragistics.Win.UltraWinGrid.ColumnStyle.Default;
                    break;
            }

            string str = string.Concat(new object[] { columnName, "|", colNotNullable ? "NN" : "", "|", colDataType.ToString(), "|", maxLength, "|", maxValue, "|", minValue, "|", caption });
            ultraGrid.DisplayLayout.Bands[0].Columns[columnName].Tag = str;
        }
        #endregion

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

        public void SetColumnTextVAlign(string columnName, VAlign vAlign)
        {
            string[] strArray = columnName.Split(new char[] { ',' });
            string key = "";
            if (strArray.Length > 0)
            {
                foreach (UltraGridBand band in Grid.DisplayLayout.Bands)
                {
                    for (int i = 0; i < strArray.Length; i++)
                    {
                        key = strArray[i].ToString();
                        if (band.Columns.Exists(key))
                        {
                            band.Columns[key].CellAppearance.TextVAlign = vAlign;
                        }
                    }
                }
            }
        }

        public void ReDrawGrid()
        {
            UltraGridBand band = Grid.DisplayLayout.Bands[0];

            int iHeight = 34;

            if (CountRows > 0)
            {
                iHeight = ((Grid.Height - band.Header.Height) - iHeight) / CountRows;
            }
            Grid.DisplayLayout.Override.DefaultRowHeight = iHeight;
        }

        private void SetGrid()
        {
            string[] sArr;

            this.BorderStyle = System.Windows.Forms.BorderStyle.None;

            sArr = _sHead.Split('|');

            if (ds.Tables[0].Columns.Count == 0)
            {
                return;
            }

            UltraGridBand band = Grid.DisplayLayout.Bands[0];

            for (int i = 0; true; i++)
            {
                string sName = "";
                string sAlign = "";
                string sWidth = "";

                string sName2 = "";

                if (ds.Tables[0].Columns.Count > i)
                {
                    sName2 = ds.Tables[0].Columns[i] == null ? "" : ds.Tables[0].Columns[i].ColumnName;
                }
                else
                {
                    sName2 = "";
                }

                if (sArr.Length > i)
                {
                    if (sArr[i] != null)
                    {
                        string[] arr = sArr[i].Split('@');
                        if (arr.Length == 2)
                        {
                            sName = arr[0];

                            string[] arr2 = arr[1].Split('^');

                            if (arr2.Length == 2)
                            {
                                sAlign = arr2[0];
                                sWidth = arr2[1];
                            }
                            else
                            {
                                sAlign = arr[1];
                            }
                        }
                        else
                        {
                            sName = sArr[i];
                            sAlign = "L";
                        }
                    }
                }
                else
                {
                    sName = "";
                }

                UltraGridColumn ugc = band.Columns[i];
                ugc.Hidden = false;

                if (sAlign == "C")
                    ugc.CellAppearance.TextHAlign = Infragistics.Win.HAlign.Center;
                else if (sAlign == "L")
                    ugc.CellAppearance.TextHAlign = Infragistics.Win.HAlign.Left;
                else if (sAlign == "R")
                    ugc.CellAppearance.TextHAlign = Infragistics.Win.HAlign.Right;
                else if (sAlign == "H")
                    ugc.Hidden = true;
                else
                    ugc.CellAppearance.TextHAlign = Infragistics.Win.HAlign.Default;

                ugc.CellAppearance.TextVAlign = VAlign.Middle;
                ugc.Header.Caption = sName == "" ? sName2 : sName;

                if (sWidth != "")
                {
                    ugc.Width = Convert.ToInt32(sWidth);
                }

                if ((i < ds.Tables[0].Columns.Count - 1 || i < sArr.Length - 1))
                {
                    continue;
                }

                break;
            }

            for (int i = 0; i < band.Columns.Count; i++)
            {
                UltraGridColumn ugc = band.Columns[i];

                if (i < FixedCols)
                {
                    ugc.CellActivation = Activation.Disabled;
                    ugc.CellAppearance.BackColor = Grid.DisplayLayout.Override.FixedCellAppearance.BackColor;
                    ugc.CellAppearance.TextHAlign = Grid.DisplayLayout.Override.FixedCellAppearance.TextHAlign;
                    ugc.CellAppearance.TextVAlign = Infragistics.Win.VAlign.Middle;
                    ugc.CellAppearance.FontData.Bold = Grid.DisplayLayout.Override.FixedCellAppearance.FontData.Bold;
                }
                else
                {
                    ugc.CellActivation = Activation.NoEdit;
                    ugc.CellAppearance.BackColor = Grid.DisplayLayout.Override.CellAppearance.BackColor;
                    ugc.CellAppearance.TextVAlign = Infragistics.Win.VAlign.Middle;
                    ugc.CellAppearance.FontData.Bold = Grid.DisplayLayout.Override.CellAppearance.FontData.Bold;
                    //ugc.CellMultiLine = Infragistics.Win.DefaultableBoolean.True;
                    ugc.CellAppearance.TextTrimming = Infragistics.Win.TextTrimming.EllipsisWord;
                }
            }

            int iHeight = 34;

            if (CountRows > 0)
            {
                iHeight = ((Grid.Height - band.Header.Height) - iHeight) / CountRows;
            }
            Grid.DisplayLayout.Override.DefaultRowHeight = iHeight;

            //Grid.DisplayLayout.Bands[0].ColHeaderLines = 2;
        }

        /// <summary>
        /// 그리드에서 사용할 조회용 커맨드
        /// </summary>
        public DbCommand SelectCommand
        {
            get { return _select; }
            set { _select = value; }
        }

        /// <summary>
        /// 그리드에서 사용할 조회 프로시져
        /// </summary>
        public string SelectProcedureName
        {
            get { return _selectStr; }
            set { _selectStr = value; }
        }

        /// <summary>
        /// SelectCommand 생성후 SelectCommand의 파라메터 리스트
        /// </summary>
        public DbParameterCollection ParameterList
        {
            get { return _select.Parameters; }
        }

        /// <summary>
        /// SelectProcedureName 를 설정한 후 사용한다.
        /// 실행 후 SelectProcedureName 에 대한 StoredProcedure 커맨드(SelectCommand)가 생성된다.
        /// </summary>
        public void SetStoreProc()
        {
            if (SelectProcedureName == null)
            {
                throw new Exception("설정된 프로시져가 없습니다.");
            }

            Configuration appConfig = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None);
            string conStr = appConfig.ConnectionStrings.ConnectionStrings["ConnectionString"].ConnectionString;
            conStr = SAMMI.Common.DecryptString(conStr);

            var builder = new ConfigurationSourceBuilder();

            builder.ConfigureData()
                   .ForDatabaseNamed("DBConn")
                     .ThatIs.ASqlDatabase()
                     .WithConnectionString(@conStr);

            var configSource = new DictionaryConfigurationSource();
            builder.UpdateConfigurationWithReplace(configSource);

            Microsoft.Practices.EnterpriseLibrary.Common.Configuration.EnterpriseLibraryContainer.Current = EnterpriseLibraryContainer.CreateDefaultContainer(configSource);

            this.db = DatabaseFactory.CreateDatabase("DBConn");
            da = db.GetDataAdapter();
            _select = db.GetStoredProcCommand(SelectProcedureName);
        }

        /// <summary>
        /// 셀 클릭시 처리 방식
        /// </summary>
        public Infragistics.Win.UltraWinGrid.CellClickAction CellClickActionType
        {
            set { Grid.DisplayLayout.Override.CellClickAction = value; }
            get { return Grid.DisplayLayout.Override.CellClickAction; }
        }

        /// <summary>
        /// 생성한 SelectCommand 와 Parameter 를 이용하여 조회한다.
        /// </summary>
        public void DoFind()
        {
            try
            {
                if (SelectProcedureName == null)
                {
                    throw new Exception("설정된 프로시져가 없습니다.");
                }

                this.Cursor = Cursors.WaitCursor;

                int iRow;

                if (Grid.ActiveRowScrollRegion.FirstRow != null)
                    iRow = Grid.ActiveRowScrollRegion.FirstRow.Index;
                else
                    iRow = 0;

                if (_select == null && ds != null)
                {
                    Grid.DataSource = ds.Tables[0];
                    SetGrid();
                }
                else
                {

                    ds = db.ExecuteDataSet(_select);

                    if (ds.Tables.Count >= 2)
                    {
                        _sHead = ds.Tables[0].Rows[0][0].ToString();

                        if (ds.Tables[0].Rows.Count == 2)
                        {
                            string[] sArr;

                            sArr = ds.Tables[0].Rows[1][0].ToString().Split('|');
                            for (int idx = 0; idx < sArr.Count(); idx++)
                            {
                                if (Grid.DisplayLayout.Bands[0].Columns.Exists(sArr[idx].Split('@')[0]))
                                    break;
                                InitColumnUltraGrid(Grid, sArr[idx].Split('@')[0], _sHead.Split('|')[idx].Split('@')[0],
                                    false, sArr[idx].Split('@')[1]);
                            }
                        }
                        Grid.DataSource = ds.Tables[1];
                        SetGrid();
                    }
                    else
                    {
                        Grid.DataSource = ds;

                        //SetGrid();
                    }


                }

                Grid.ActiveRowScrollRegion.FirstRow = Grid.Rows[iRow];

                _row = null;
                _column = null;

                SetUpDownButton();

                this.Cursor = Cursors.Default;
            }
            catch (SqlException ex)
            {
                this.Cursor = Cursors.Default;

                throw ex;
            }
            catch (Exception)
            {
                this.Cursor = Cursors.Default;

                return;
            }
        }

        //오라클 사용
        public void DoFind_Oracle(DataSet pDs)
        {
            try
            {
                //if (SelectProcedureName == null)
                //{
                //    throw new Exception("설정된 프로시져가 없습니다.");
                //}

                this.Cursor = Cursors.WaitCursor;

                int iRow;

                if (Grid.ActiveRowScrollRegion.FirstRow != null)
                    iRow = Grid.ActiveRowScrollRegion.FirstRow.Index;
                else
                    iRow = 0;


                //설정 및 결과정보 수신
                ds = pDs;

                if (ds.Tables.Count >= 2)
                {
                    _sHead = ds.Tables[0].Rows[0][0].ToString();

                    if (ds.Tables[0].Rows.Count == 2)
                    {
                        string[] sArr;

                        sArr = ds.Tables[0].Rows[1][0].ToString().Split('|');
                        for (int idx = 0; idx < sArr.Count(); idx++)
                        {
                            if (Grid.DisplayLayout.Bands[0].Columns.Exists(sArr[idx].Split('@')[0]))
                                break;
                            InitColumnUltraGrid(Grid, sArr[idx].Split('@')[0], _sHead.Split('|')[idx].Split('@')[0],
                                false, sArr[idx].Split('@')[1]);
                        }
                    }
                    Grid.DataSource = ds.Tables[1];
                    SetGrid();
                }

                //설정정보가 없는 경우 검색 결과만 저장
                else
                {
                    Grid.DataSource = ds;
                }

                if (Grid.Rows.Count > 0)
                {
                    //결과 출력후 그리드 초기화
                    Grid.ActiveRowScrollRegion.FirstRow = Grid.Rows[iRow];
                }

                _row = null;
                _column = null;

                SetUpDownButton();

                this.Cursor = Cursors.Default;
            }
            catch (SqlException ex)
            {
                this.Cursor = Cursors.Default;

                throw ex;
            }
            catch (Exception)
            {
                this.Cursor = Cursors.Default;

                return;
            }
        }

        /// <summary>
        /// 페이지 변경
        /// </summary>
        /// <param name="type">페이지 변경 방향</param>
        /// <param name="iPageMove">페이지 변경 셀 수량</param>
        public void PageMove(MESButton btn, SmartDas.Components.MESButton.LinkGridButtonType type, int iPageMove)
        {
            int iPoint;

            if (Grid != null)
            {
                if (Grid.Rows.Count <= 1)
                    return;
            }
            else
            {
                return;
            }

            this.Cursor = Cursors.WaitCursor;

            switch (type) //데이터가 없으면 버튼을 클릭못하게
            {
                case MESButton.LinkGridButtonType.Down:
                    DownButton = btn;

                    if (Grid.ActiveRowScrollRegion.FirstRow.Index + iPageMove > Grid.Rows.Count - CountRows)
                    {
                        if (Grid.Rows.Count - (CountRows == 0 ? 1 : CountRows) < 0)
                        {
                            iPoint = 0;
                        }
                        else
                        {
                            iPoint = Grid.Rows.Count - (CountRows == 0 ? 1 : CountRows);
                        }
                        btn.Enabled = false;

                    }
                    else
                    {
                        iPoint = Grid.ActiveRowScrollRegion.FirstRow.Index + iPageMove;

                        btn.Enabled = true;
                    }

                    Grid.ActiveRowScrollRegion.FirstRow = Grid.Rows[iPoint];

                    SetUpDownButton();
                    break;
                case MESButton.LinkGridButtonType.Up:
                    UpButton = btn;

                    if (Grid.ActiveRowScrollRegion.FirstRow.Index - iPageMove < 0)
                    {
                        iPoint = 0;

                        btn.Enabled = false;
                    }
                    else
                    {
                        iPoint = Grid.ActiveRowScrollRegion.FirstRow.Index - iPageMove;

                        btn.Enabled = true;
                    }

                    Grid.ActiveRowScrollRegion.FirstRow = Grid.Rows[iPoint];

                    SetUpDownButton();
                    break;
            }

            this.Cursor = Cursors.Default;
        }

        /// <summary>
        /// 페이지 변경_2
        /// </summary>
        /// <param name="type">페이지 변경 방향</param>
        /// <param name="iPageMove">페이지 변경 셀 수량</param>
        public void PageMove(MESButton_Top btn, SmartDas.Components.MESButton_Top.LinkGridButtonType type, int iPageMove)
        {
            int iPoint;

            if (Grid != null)
            {
                if (Grid.Rows.Count <= 1)
                    return;
            }
            else
            {
                return;
            }

            this.Cursor = Cursors.WaitCursor;

            switch (type) //데이터가 없으면 버튼을 클릭못하게
            {
                case MESButton_Top.LinkGridButtonType.Down:
                    DownButton_Top = btn;

                    if (Grid.ActiveRowScrollRegion.FirstRow.Index + iPageMove > Grid.Rows.Count - CountRows)
                    {
                        if (Grid.Rows.Count - (CountRows == 0 ? 1 : CountRows) < 0)
                        {
                            iPoint = 0;
                        }
                        else
                        {
                            iPoint = Grid.Rows.Count - (CountRows == 0 ? 1 : CountRows);
                        }
                        btn.Enabled = false;

                    }
                    else
                    {
                        iPoint = Grid.ActiveRowScrollRegion.FirstRow.Index + iPageMove;

                        btn.Enabled = true;
                    }

                    Grid.ActiveRowScrollRegion.FirstRow = Grid.Rows[iPoint];

                    SetUpDownButton();
                    break;
                case MESButton_Top.LinkGridButtonType.Up:
                    UpButton_Top = btn;

                    if (Grid.ActiveRowScrollRegion.FirstRow.Index - iPageMove < 0)
                    {
                        iPoint = 0;

                        btn.Enabled = false;
                    }
                    else
                    {
                        iPoint = Grid.ActiveRowScrollRegion.FirstRow.Index - iPageMove;

                        btn.Enabled = true;
                    }

                    Grid.ActiveRowScrollRegion.FirstRow = Grid.Rows[iPoint];

                    SetUpDownButton();
                    break;
            }

            this.Cursor = Cursors.Default;
        }

        private void SetUpDownButton()
        {
            if (UpButton_Top != null)
            {
                UpButton_Top.Enabled = !(Grid.ActiveRowScrollRegion.FirstRow.Index == 0);
            }

            if (DownButton_Top != null)
            {
                DownButton_Top.Enabled = !(Grid.ActiveRowScrollRegion.FirstRow.Index >= Grid.Rows.Count - CountRows);
            }
        }

        /// <summary>
        /// 고정 컬럼 수
        /// </summary>
        public int FixedCols
        {
            get { return _FixedCols; }
            set { _FixedCols = value; }
        }

        /// <summary>
        /// 기본으로 설정할 로우 숫자
        /// </summary>
        public int CountRows
        {
            get { return _CountRow; }
            set { _CountRow = value; }
        }

        /// <summary>
        /// 폰트의 크기를 설정하거나 가져온다.
        /// </summary>
        public float FontSize
        {
            get { return Grid.Font.Size; }
            set
            {
                Font dFont = (Font)(Grid.Font.Clone());
                Grid.Font = new Font(dFont.FontFamily, value, dFont.Style);
            }
        }

        /// <summary>
        /// 폰트의 크기를 설정하거나 가져온다.
        /// </summary>
        public float HeaderFontSize
        {
            get { return Grid.DisplayLayout.Override.HeaderAppearance.FontData.SizeInPoints; }
            set
            {
                Grid.DisplayLayout.Override.HeaderAppearance.FontData.SizeInPoints = value;
            }
        }

        /// <summary>
        /// 데이터 로우 리스트
        /// </summary>
        public RowsCollection Rows
        {
            get { return Grid.Rows; }
        }

        /// <summary>
        /// 컬럼 리스트
        /// </summary>
        public ColumnsCollection Columns
        {
            get { return Grid.DisplayLayout.Bands[0].Columns; }
        }

        /// <summary>
        /// 그리드 클릭 이벤트 아규먼트
        /// </summary>
        public class GridClickEventArg
        {
            public UltraGridRow row;
            public UltraGridColumn column;

            public UltraGridCell cell;

            public GridClickEventArg(UltraGridCell cell)
            {
                this.cell = cell;
                this.row = cell.Row;
                this.column = cell.Column;
            }
        }

        /// <summary>
        /// 그리드 셀 클릭시 발생
        /// </summary>
        public delegate void gridClick(object sender, GridClickEventArg e);

        public event gridClick GridClick;

        private void OnGridClickEvent(object obj, GridClickEventArg e)
        {
            if (GridClick != null)
            {
                GridClick(obj, e);
            }
        }

        private void Grid_ClickCell(object sender, ClickCellEventArgs e)
        {
            GridClickEventArg ne = new GridClickEventArg(e.Cell);

            _row = ne.row;
            _column = ne.column;

            //Console.WriteLine(string.Format("Grid_ClickCell {0}, {1}", _row, _column));
            OnGridClickEvent(this, ne);
        }

        /// <summary>
        /// 그리드 셀 클릭시 발생
        /// </summary>
        public delegate void gridClickCellButton(object sender, GridClickEventArg e);

        public event gridClickCellButton ClickCellButton;

        private void OnClickCellButtonEvent(object obj, GridClickEventArg e)
        {
            if (ClickCellButton != null)
            {
                ClickCellButton(obj, e);
            }
        }

        private void Grid_ClickCellButton(object sender, CellEventArgs e)
        {
            GridClickEventArg ne = new GridClickEventArg(e.Cell);

            _row = ne.row;
            _column = ne.column;

            OnClickCellButtonEvent(this, ne);
        }


        /// <summary>
        /// 그리드 셀 더블클릭시 발생
        /// </summary>
        public delegate void gridDoubleClick(object sender, GridClickEventArg e);

        public event gridDoubleClick GridDoubleClick;

        private void OnGridDoubleClickEvent(object obj, GridClickEventArg e)
        {
            if (GridDoubleClick != null)
            {
                GridDoubleClick(obj, e);
            }
        }
        private void Grid_DoubleClickCell(object sender, DoubleClickCellEventArgs e)
        {
            GridClickEventArg ne = new GridClickEventArg(e.Cell);

            _row = ne.row;
            _column = ne.column;

            OnGridDoubleClickEvent(this, ne);
        }

        /// <summary>
        /// 그리드 선택 변경시 발생
        /// </summary>
        public delegate void gridSelectChanged(object sender, AfterSelectChangeEventArgs e);

        public event gridSelectChanged GridSelectChanged;

        private void OnGridSelectChangedEvent(object obj, AfterSelectChangeEventArgs e)
        {
            if (GridSelectChanged != null)
            {
                GridSelectChanged(obj, e);
            }
        }

        private void Grid_AfterSelectChange(object sender, AfterSelectChangeEventArgs e)
        {
            if (GridSelectChanged != null)
            {
                if (Grid.ActiveRow != null)
                {
                    // column 을 가져오는것은 찾지 못하여 Row만 변경하도록함.
                    // column 은 차후 추가 필요
                    _row = Grid.ActiveRow;
                    //System.Diagnostics.Debug.WriteLine("Grid_AfterSelectChange");
                    OnGridSelectChangedEvent(this, e);
                }
            }
        }

        /// <summary>
        /// 선택된 로우
        /// </summary>
        public UltraGridRow Row
        {
            get { return _row; }
            set
            {
                Grid.ActiveRow = value;
                _row = Grid.ActiveRow;
            }
        }

        /// <summary>
        /// 선택된 컬럼
        /// </summary>
        public UltraGridColumn Col
        {
            get { return _column; }
        }
    }

    public class CF : IUIElementCreationFilter
    {
        #region IUIElementCreationFilter Members

        public void AfterCreateChildElements(UIElement parent)
        {
            CellUIElement cellElement = parent as CellUIElement;
            if (cellElement != null && cellElement.Column.Key == "BarPrint")
            {
                CellButtonUIElement buttonElement = cellElement.GetDescendant(typeof(CellButtonUIElement)) as CellButtonUIElement;
                if (buttonElement != null)
                {
                    Rectangle originalRect = buttonElement.Rect;
                    buttonElement.Rect = new Rectangle(
                        new Point(originalRect.Location.X + 2, originalRect.Location.Y + 2),
                        new Size(originalRect.Size.Width - 4, originalRect.Size.Height - 4));
                }
            }
        }

        public bool BeforeCreateChildElements(UIElement parent)
        {
            return false;
        }

        #endregion
    }
}