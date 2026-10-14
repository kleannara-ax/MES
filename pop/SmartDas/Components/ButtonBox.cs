using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;

using System.Collections.ObjectModel;
using System.Collections;
using System.Configuration;
using Microsoft.Practices.EnterpriseLibrary.Data;
using System.Data.Common;
using System.Data.SqlClient;
using Microsoft.Practices.EnterpriseLibrary.Common.Configuration;

using SAMMI;

namespace SmartDas.Components
{
    public partial class ButtonBox : UserControl
    {
        #region 멤버변수 리스트
        private int _CountX = 1;
        private int _CountY = 1;

        private int _iPage = 0;
        private int _MaxPage = 0;

        //private float _FontSize = 0;

        private Padding _MarginIn;
        private Padding _MarginOut;

        private ButtonBoxTypeEnum _bType;
        private SelectionModeEnum _sMode;

        private MESButton UpButton;
        private MESButton DownButton;
        private MESButton_Top UpButton_Top;
        private MESButton_Top DownButton_Top;

        private List<MESButton> _btnList = new List<MESButton>();
        private List<ButtonData> _dataList = new List<ButtonData>();

        private List<ButtonData> _SelList = new List<ButtonData>();

        private string _exTag = "";

        private string _sMajorCode = "";
        private string _sAllCode = "";
        private string _sAllName = "";
        private string _sInitCode = "";

        Database db;
        DataSet ds;

        private DbCommand _select;
        private string _selectStr; 
        private int iDoFindResultCount = 0;


        DbDataAdapter da;

        private bool bButtonEvent = false;
        #endregion

        #region 이벤트
        public class ButtonClickEventArg
        {
            public int x;
            public int y;

            public ButtonClickEventArg(int x, int y)
            {
                this.x = x;
                this.y = y;
            }
        }

        public delegate void ButtonClick(MESButton sender, ButtonClickEventArg e);

        public delegate void ButtonChange(MESButton sender, ButtonClickEventArg e);

        public event ButtonClick buttonClickEvent;

        private void OnButtonClickEvent(MESButton btn, ButtonClickEventArg e)
        {
            if (buttonClickEvent != null)
            {
                buttonClickEvent(btn, e);
            }
        }

        public event ButtonChange buttonChangeEvent;

        private void OnButtonChangeEvent(MESButton btn, ButtonClickEventArg e)
        {
            if (buttonChangeEvent != null)
            {
                buttonChangeEvent(btn, e);
            }
        }
        #endregion

        #region enum
        /// <summary>
        /// 버튼 박스 타입
        /// </summary>
        public enum ButtonBoxTypeEnum
        {
            /// <summary>
            /// 버튼으로 구성
            /// </summary>
            Buttons,
            /// <summary>
            /// 선택 가능한 버튼으로 구성
            /// </summary>
            Selection
        }

        /// <summary>
        /// NewButtonBox 선택 방식
        /// </summary>
        public enum SelectionModeEnum
        {
            /// <summary>
            /// 선택할 수 없음.
            /// </summary>
            None,
            /// <summary>
            /// 하나만 선택할 수 있음.
            /// </summary>
            Single,
            /// <summary>
            /// 여러개를 선택할 수 있음.
            /// </summary>
            Multiple
        }
        #endregion

        #region Property 리스트
        /// <summary>
        /// 버튼 타입
        /// </summary>
        public ButtonBoxTypeEnum ButtonBoxType
        {
            get { return _bType; }
            set { _bType = value; }
        }

        /// <summary>
        /// 버튼 선택 형태
        /// </summary>
        public SelectionModeEnum SelectionMode
        {
            get { return _sMode; }
            set { _sMode = value; }
        }

        /// <summary>
        /// 컨트롤 내부에 버튼이 가로로 존재할 수 있는 수량
        /// </summary>
        public int CountX
        {
            get { return _CountX; }
            set
            {
                _CountX = value < 1 ? 1 : value;
            }
        }

        /// <summary>
        /// 컨트롤 내부에 버튼이 세로로 존재할 수 있는 수량
        /// </summary>
        public int CountY
        {
            get { return _CountY; }
            set
            {
                _CountY = value < 1 ? 1 : value;
            }
        }

        /// <summary>
        /// 버튼 박스에서 사용할 조회용 커맨드
        /// </summary>
        public DbCommand SelectCommand
        {
            get { return _select; }
            set { _select = value; }
        }

        /// <summary>
        /// 버튼 박스에서 사용할 조회 프로시져
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
        /// 버튼과 버튼 사이의 간격
        /// </summary>
        public Padding MarginIn
        {
            get { return _MarginIn; }
            set { _MarginIn = value; }
        }

        /// <summary>
        /// 컨트롤 테두리와 버튼 사이의 간격
        /// </summary>
        public Padding MarginOut
        {
            get { return _MarginOut; }
            set { _MarginOut = value; }
        }

        public string ExTag
        {
            get { return _exTag; }
            set { _exTag = value; }
        }

        public ButtonData this[int ix, int iy]
        {
            get
            {
                string sBtnName = "BtnBox " + ix.ToString() + " " + iy.ToString();

                foreach (ButtonData btn in _dataList)
                {
                    if (btn.Name == sBtnName)
                    {

                        return btn;
                    }
                }

                return null;
            }
        }

        public ButtonData this[string sButtonName]
        {
            get
            {
                foreach (ButtonData btn in _dataList)
                {
                    if (btn.Name == sButtonName)
                    {
                        return btn;
                    }
                }

                return null;
            }
        }

        public int CurrentPage
        {
            set { _iPage = value; }
            get { return _iPage; }
        }

        /// <summary>
        /// 폰트의 크기를 설정하거나 가져온다.
        /// </summary>
        public float FontSize
        {
            get { return this.Font.Size; }
            set 
            {
                Font dFont = (Font)(this.Font.Clone());
                this.Font = new Font(dFont.FontFamily, value, dFont.Style);
            }
        }
        /// <summary>
        /// DoFind 로 조회한 데이터의 갯수
        /// </summary>
        public int DoFindResultCount
        {
            get { return iDoFindResultCount; }
        }

        #endregion

        #region 생성자
        /// <summary>
        /// 버튼을 2차원 배열에 담을 수 있는 컨트롤
        /// </summary>
        public ButtonBox()
        {
            InitializeComponent();

            SetStyle(ControlStyles.AllPaintingInWmPaint, true);
            SetStyle(ControlStyles.DoubleBuffer, true);
            SetStyle(ControlStyles.UserPaint, true);

            ds = new DataSet();

            _bType = ButtonBoxTypeEnum.Selection;
            _sMode = SelectionModeEnum.Single;

            _MarginIn = new System.Windows.Forms.Padding(3, 3, 3, 3);
            _MarginOut = new System.Windows.Forms.Padding(3, 3, 3, 3);
        }
        #endregion

        #region 메소드 일람
        /// <summary>
        /// SelectProcedureName 를 설정한 후 사용한다.
        /// 실행 후 SelectProcedureName 에 대한 StoredProcedure 커맨드(SelectCommand)가 생성된다.
        /// </summary>
        public void SetStoreProc()
        {
            if (_selectStr == null)
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

            if (_selectStr == "CodeName")
            {
                string sSQL = "";

                sSQL = "Select MinorCode, CodeName" + "\n";
                sSQL += "   , case when MinorCode = '" + _sInitCode + "' then 'Y' else 'N' end Selected " + "\n";
                sSQL += "   , Enabled, '' as ExTag, RelCode1, RelCode2, RelCode3, RelCode4, RelCode5 " + "\n";
                sSQL += "   from ( " + "\n";

                if (_sAllCode != "" || _sAllName != "")
                {
                    sSQL += "Select '" + _sAllCode + "' as MinorCode, '" + _sAllName + "' as CodeName, 'Y' as Enabled " + "\n";
                    sSQL += "       , '' as RelCode1, '' as RelCode2, '' as RelCode3, '' as RelCode4, '' as RelCode5 " + "\n";
                    sSQL += "Union " + "\n";
                }
                
                sSQL += "Select MinorCode, CodeName, 'Y' " + "\n";
                sSQL += "       , RelCode1, RelCode2, RelCode3, RelCode4, RelCode5 " + "\n";
	            sSQL += "       from TBM0000 " + "\n";
                sSQL += "       	where MajorCode = '" + _sMajorCode + "' " + "\n";
                sSQL += "       	  and MinorCode <> '$' " + "\n";
                sSQL += "             and UseFlag = 'Y' " + "\n";
                sSQL += "   ) a " + "\n";

                _select = db.GetSqlStringCommand(sSQL);
            }
            else
            {
                
                _select = db.GetStoredProcCommand(_selectStr);
            }
        }

        /// <summary>
        /// 생성한 SelectCommand 와 Parameter 를 이용하여 조회한다.
        /// </summary>
        public void DoFind()
        {
            try
            {
                if (_select == null)
                {
                    throw new Exception("설정된 프로시져가 없습니다.");
                }

                ds = db.ExecuteDataSet(_select);
                MakeButtons();

                _iPage = 0;
                RedrawButtons();
            }
            catch (SqlException ex)
            {
                throw ex;
            }
            catch (Exception)
            {
                return;
            }
        }

        //오라클 버튼목록 조회(SetStoreProc 미사용)
        public void DoFind_Oracle(DataSet pDs)
        {
            try
            {
                //if (_select == null)
                //{
                //    throw new Exception("설정된 프로시져가 없습니다.");
                //}

                ds = pDs;
                MakeButtons();

                _iPage = 0;
                RedrawButtons();
            }
            catch (SqlException ex)
            {
                throw ex;
            }
            catch (Exception)
            {
                return;
            }
        }

        public List<ButtonData> GetButtonList()
        {
            return _dataList;
        }

        public List<ButtonData> GetSelectedButtons()
        {
            return _SelList;
        }

        public List<MESButton> GetShowdButtons()
        {
            return _btnList;
        }

        private void MakeButtons()
        {
            try
            {
                int i = 0, j = 0;

                if (_CountX < 1)
                {
                    _CountX = 1;
                }

                if (_CountY < 1)
                {
                    _CountY = 1;
                }

                _btnList.Clear();
                _SelList.Clear();
                _dataList.Clear();

                int iCount = 0;

                for (int x = 0; x < ds.Tables[0].Rows.Count; x++)
                {
                    DataRow dr = ds.Tables[0].Rows[x];

                    string sCode = dr[0].ToString();
                    string sText = dr[1].ToString();
                    string sSel = dr[2].ToString();
                    string sUse = dr[3].ToString();

                    string sExTag = "";

                    if (ds.Tables[0].Columns.Count >= 5)
                    {
                        sExTag = dr[4].ToString();
                    }

                    ButtonData t = new ButtonData();

                    t.Name = "BtnBox " + i.ToString() + " " + j.ToString();

                    t.Text = sText.Replace("\\n", "\n" );
                    t.Tag = sCode;

                    _dataList.Add(t);

                    t.UseFlag = sUse == "Y";
                    t.ButtonPressed = sSel == "Y";
                    t.ExTag = sExTag;

                    if (ds.Tables[0].Columns.Count > 5)
                    {
                        for (int ig = 5; ig < ds.Tables[0].Columns.Count; ig++)
                        {
                            t.SetValue(ds.Tables[0].Columns[ig].ColumnName, clsDB.nvlString(dr[ig]));
                        }
                    }

                    if (j < _CountX - 1)
                    {
                        j++;
                    }
                    else
                    {
                        j = 0;
                        i++;
                    }
                    iCount++;
                }

                iDoFindResultCount = iCount;

                SetButtons();

                this.BorderStyle = System.Windows.Forms.BorderStyle.None;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        /// <summary>
        /// 버튼을 그린다.
        /// </summary>
        public void SetButtons()
        {
            try
            {
                bool bMakeButtonData = false;
                int thisWidth = this.Width;
                int thisHeight = this.Height;

                int pWidth;
                int pHeight;

                if (_CountX < 1)
                {
                    _CountX = 1;
                }

                if (_CountY < 1)
                {
                    _CountY = 1;
                }

                this.Controls.Clear();

                bMakeButtonData = _dataList.Count == 0;

                pWidth = (thisWidth - (_MarginOut.Left + _MarginOut.Right) - ((_CountX - 1) * (_MarginIn.Left + _MarginIn.Right))) / _CountX;
                pHeight = (thisHeight - (_MarginOut.Top + _MarginOut.Bottom) - ((_CountY - 1) * (_MarginIn.Top + _MarginIn.Bottom))) / _CountY;

                for (int i = 0; i < _CountY; i++)
                {
                    for (int j = 0; j < _CountX; j++)
                    {
                        int iLeft = _MarginOut.Left + (j * (_MarginIn.Left + _MarginIn.Right + pWidth));
                        int iTop = _MarginOut.Top + (i * (_MarginIn.Top + _MarginIn.Bottom + pHeight));

                        MESButton t = new MESButton();
                        
                        t.Left = iLeft;
                        t.Top = iTop;
                        t.Width = pWidth;
                        t.Height = pHeight;

                        t.ParentBox = this;
                        t.Name = "BtnBox " + i.ToString() + " " + j.ToString();
                        t.Tag = i.ToString() + " " + j.ToString();

                        //***********************************************************
                        // 220602 : 문제점 
                        // _bType이 Selection 인경우 버튼 에서 MouseDown 하여 마우스로 이동하여 버튼 영역을 벗아나서 MouseUP 할경우 Click 이벤트가 발생안함.
                        // 수정 사항
                        // 이전에 Click 이벤트에서 만 버튼 처리한것을.
                        // _bType이 Button 이면 이전과 동일하게 Click이베트에서 버튼 처리 하고, Selection 이면 MouseDown 이벤트 에서 버튼 처리 하도록 수정함.
                        //***********************************************************

                        //t.Click += new EventHandler(Button_Click);

                        if (_bType == ButtonBoxTypeEnum.Selection)
                        {
                            t.MouseDown += new MouseEventHandler(Button_MouseDown_Click);
                            //t.MouseUp += new MouseEventHandler(Button_MouseUp_Click);

                            t.ButtonClickType = MESButton.ButtonClickTypeEnum.Change;
                        }
                        else
                        {
                            t.Click += new EventHandler(Button_Click);

                            t.ButtonClickType = MESButton.ButtonClickTypeEnum.Click;
                        }

                        t.Font = this.Font;

                        _btnList.Add(t);

                        if (bMakeButtonData)
                        {
                            ButtonData tt = new ButtonData();
                            tt.SetData(t);
                            _dataList.Add(tt);
                        }

                        this.Controls.Add(t);
                    }
                }

                this.BorderStyle = System.Windows.Forms.BorderStyle.None;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public void RedrawButtons()
        {
            int thisWidth = this.Width;
            int thisHeight = this.Height;

            int pWidth;
            int pHeight;

            try
            {
                if (_CountX < 1)
                {
                    _CountX = 1;
                }

                if (_CountY < 1)
                {
                    _CountY = 1;
                }

                if (_btnList.Count == 0 && _dataList.Count == 0)
                    return;

                pWidth = (thisWidth - (_MarginOut.Left + _MarginOut.Right) - ((_CountX - 1) * (_MarginIn.Left + _MarginIn.Right))) / _CountX;
                pHeight = (thisHeight - (_MarginOut.Top + _MarginOut.Bottom) - ((_CountY - 1) * (_MarginIn.Top + _MarginIn.Bottom))) / _CountY;

                for (int i = 0; i < _CountY; i++)
                {
                    for (int j = 0; j < _CountX; j++)
                    {
                        //NewMESButton btn = this[i + _iPage, j];
                        // 변경할 페이지의 버튼 정보
                        ButtonData btn = GetButton(i + _iPage, j);

                        int iLeft = _MarginOut.Left + (j * (_MarginIn.Left + _MarginIn.Right + pWidth));
                        int iTop = _MarginOut.Top + (i * (_MarginIn.Top + _MarginIn.Bottom + pHeight));

                        //if (btn != null)
                        //{
                            for (int k = 0; k < this.Controls.Count; k++)
                            {
                                if (Controls[k].Left == iLeft && Controls[k].Top == iTop)
                                {
                                    MESButton con = (MESButton)Controls[k];

                                    if (btn != null)
                                    {
                                        con.btnData = null;
                                        btn.MappingButton = con;

                                        con.Tag = btn.Tag;
                                        con.Text = btn.Text;
                                        con.Name = btn.Name;
                                        con.UseFlag = true;
                                        con.ButtonPressed = btn.ButtonPressed;
                                        con.UseFlag = btn.UseFlag;
                                        con.ExTag = btn.ExTag;

                                        con.btnData = btn;

                                        if (btn.bAlarm)
                                        {
                                            con.SetAlarmBackColor();
                                        }
                                        else
                                        {
                                            con.SetAlarmBackColor(true);
                                        }
                                    }
                                    else
                                    {
                                    
                                        con.Tag = false;
                                        con.Text = "";
                                        con.btnData = null;
                                        con.ButtonPressed = false;
                                        con.UseFlag = false;
                                    }
                                    break;
                                }
                            }
                        //}
                    }
                }

                SetSelectButtons();

                SetUpDownButton();
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public void PageMove(MESButton btn, SmartDas.Components.MESButton.LinkGridButtonType link, int iSize)
        {
            switch (link)
            {
                case MESButton.LinkGridButtonType.Up:
                    UpButton = btn;

                    if (_iPage - iSize <= 0)
                    {
                        _iPage = 0;
                    }
                    else
                    {
                        _iPage = _iPage - iSize;
                    }

                    RedrawButtons();
                    break;
                case MESButton.LinkGridButtonType.Down:
                    DownButton = btn;

                    SetMaxPage();
#if true
                    // bugfix : 마지막 페이지인경우 _Maxpage를 지정할경우 마지막 페이지 한줄을 표시하는 현상 수정을 위해서 주석처리함.
                    if (_iPage + iSize <= _MaxPage)
                    {
                        _iPage = _iPage + iSize;
                    }
#else
                    if (_iPage + iSize >= _MaxPage)
                    {
                        _iPage = _MaxPage;
                    }
                    else
                    {
                        _iPage = _iPage + iSize;
                    }
#endif
                    RedrawButtons();
                    break;
            }
        }

        public void PageMove(MESButton_Top btn, SmartDas.Components.MESButton_Top.LinkGridButtonType link, int iSize)
        {
            switch (link)
            {
                case MESButton_Top.LinkGridButtonType.Up:
                    UpButton_Top = btn;

                    if (_iPage - iSize <= 0)
                    {
                        _iPage = 0;
                    }
                    else
                    {
                        _iPage = _iPage - iSize;
                    }

                    RedrawButtons();
                    break;
                case MESButton_Top.LinkGridButtonType.Down:
                    DownButton_Top = btn;

                    SetMaxPage();
#if true
                    // bugfix : 마지막 페이지인경우 _Maxpage를 지정할경우 마지막 페이지 한줄을 표시하는 현상 수정을 위해서 주석처리함.
                    if (_iPage + iSize <= _MaxPage)
                    {
                        _iPage = _iPage + iSize;
                    }
#else
                    if (_iPage + iSize >= _MaxPage)
                    {
                        _iPage = _MaxPage;
                    }
                    else
                    {
                        _iPage = _iPage + iSize;
                    }
#endif
                    RedrawButtons();
                    break;
            }
        }

        private void SetUpDownButton()
        {
            if (DownButton != null)
            {
                DownButton.Enabled = _iPage < _MaxPage;
            }

            if (UpButton != null)
            {
                UpButton.Enabled = _iPage != 0;
            }
        }

        private void Button_MouseDown_Click(object sender, EventArgs e)
        {
            if (!bButtonEvent)
            {
                bButtonEvent = true;
                MESButton t = (MESButton)sender;
                ButtonData btn = t.btnData;
                //btn.UseFlag = t.UseFlag;
                //btn.ButtonPressed = t.ButtonPressed;
                //btn.ExTag = t.ExTag;

                int ix, iy;

                string[] sArr = t.Name.Split(' ');
                ix = Convert.ToInt32(sArr[1]);
                iy = Convert.ToInt32(sArr[2]);

                ButtonClickEventArg ne = new ButtonClickEventArg(ix, iy);

                switch (_bType)
                {
                    case ButtonBoxTypeEnum.Buttons:
                        OnButtonClickEvent(t, ne);
                        break;
                    case ButtonBoxTypeEnum.Selection:
                        SetSelectButtons(btn);
                        OnButtonChangeEvent(t, ne);
                        break;
                }
                bButtonEvent = false;
            }
        }

        //private void Button_MouseUp_Click(object sender, EventArgs e)
        //{
        //    Console.WriteLine("Button_MouseUp_Click");

        //}

        private void Button_Click(object sender, EventArgs e)
        {
            if (!bButtonEvent)
            {
                bButtonEvent = true;
                MESButton t = (MESButton)sender;
                ButtonData btn = t.btnData;
                //btn.UseFlag = t.UseFlag;
                //btn.ButtonPressed = t.ButtonPressed;
                //btn.ExTag = t.ExTag;

                int ix, iy;

                string[] sArr = t.Name.Split(' ');
                ix = Convert.ToInt32(sArr[1]);
                iy = Convert.ToInt32(sArr[2]);

                ButtonClickEventArg ne = new ButtonClickEventArg(ix, iy);

                switch (_bType)
                {
                    case ButtonBoxTypeEnum.Buttons:
                        OnButtonClickEvent(t, ne);
                        break;
                    case ButtonBoxTypeEnum.Selection:
                        SetSelectButtons(btn);
                        OnButtonChangeEvent(t, ne);
                        break;
                }
                bButtonEvent = false;
            }
        }

        public void SetSelectButtons(ButtonData t)
        {
            switch (_sMode)
            {
                case SelectionModeEnum.None:
                    t.ButtonPressed = false;
                    RedrawButtons();
                    break;
                case SelectionModeEnum.Single:
                    _SelList.Clear();

                    foreach (ButtonData btn in _dataList)
                    {
                        if (btn.Name != t.Name)
                        {
                            if (btn.ButtonPressed)
                            {
                                if (btn.MappingButton != null)
                                {
                                    btn.MappingButton.btnData = null;
                                    btn.ButtonPressed = false;
                                    btn.MappingButton.btnData = btn;
                                }
                                else
                                {
                                    btn.ButtonPressed = false;
                                }
                            }
                        }
                        else
                        {
                            btn.MappingButton.btnData = null;
                            btn.ButtonPressed = true;
                            btn.MappingButton.btnData = btn;
                        }
                    }

                    RedrawButtons();
                    break;
                case SelectionModeEnum.Multiple:
                    _SelList.Clear();
                    foreach (ButtonData me in _dataList)
                    {
                        if (me.ButtonPressed)
                        {
                            _SelList.Add(me);
                        }
                    }
                    break;
            }
        }

        public void SetSelectedButton(string sName)
        {
            _SelList.Clear();

            foreach (ButtonData btn in _dataList)
            {
                if (btn.ExTag != sName)
                {
                    if (btn.ButtonPressed)
                    {
                        if (btn.MappingButton != null)
                        {
                            btn.MappingButton.btnData = null;
                            btn.ButtonPressed = false;
                            btn.MappingButton.btnData = btn;
                        }
                        else
                        {
                            btn.ButtonPressed = false;
                        }
                    }
                }
                else
                {
                    btn.MappingButton.btnData = null;
                    btn.ButtonPressed = true;
                    btn.MappingButton.btnData = btn;
                }
            }

            RedrawButtons();
        }

        public void SetSelectButtons()
        {
            _SelList.Clear();

            foreach (ButtonData btn in _dataList)
            {
                if (btn.ButtonPressed)
                {
                    foreach (MESButton b in _btnList)
                    {
                        if (b.Name == btn.Name)
                        {
                            break;
                        }
                    }

                    _SelList.Add(btn);
                }
            }
        }

        private void NewButtonBox_Resize(object sender, EventArgs e)
        {
            RedrawButtons();
        }

        public ButtonData GetButtonByTag(string sTag)
        {
            foreach (ButtonData btn in _dataList)
            {
                if (btn.Tag.ToString() == sTag)
                {
                    return btn;
                }
            }

            return null;
        }

        private ButtonData GetButton(int ix, int iy)
        {
            int iPoint = (ix * _CountX) + iy;
            int i = 0, t = 0;

            // ButtonBox 의 ExTag값이 empty 인경우 Control에서 사라져서 계속 오류가발생함.
            // ExTag가 사라지지않게 하기 위해서 "-"를 넣어서 임시방편으로 사용
            if (_exTag == "" || _exTag == "-")
            {
                return this[ix, iy];
            }

            for (; i < _dataList.Count; i++)
            {
                ButtonData btn = _dataList[i];

                if (btn.ExTag == _exTag)
                {
                    if (iPoint == t)
                    {
                        return btn;
                    }

                    t++;
                }
            }

            return null;
        }

        private void SetMaxPage()
        {
            int t = 0;

            if (_exTag != "")
            {
                for (int i = 0; i < _dataList.Count; i++)
                {
                    ButtonData btn = _dataList[i];

                    if (btn.ExTag == _exTag)
                    {
                        t++;
                    }
                }
            }
            else
            {
                t = _dataList.Count;
            }

            _MaxPage = ((t - 1) / _CountX);

            return;
        }

        public void SetCommonCode(string MajorCode, string sInitValue, string sAllCode, string sAllName, bool bFront = true)
        {
            this.SelectProcedureName = "CodeName";
            _sMajorCode = MajorCode;

            _sAllCode = sAllCode;
            _sAllName = sAllName;

            _sInitCode = sInitValue;
        }
        #endregion
    }
}
