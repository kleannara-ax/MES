using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace SmartDas.Components
{
    [DefaultEvent("Click")]
    public partial class MESButton_Bottom : UserControl
    {
        #region 멤버 변수
        private MESGrid _grid;
        private ButtonBox _bBox;

        private ButtonBox _parent;

        private LinkGridButtonType _link;
        private Color _bColor;
        private Color _bDisColor;

        private Color _ClickColor;
        private Color _AlramColor;

        public ButtonData btnData;

        private object _tag;
        private int _iSize;

        private bool _bPress = false;
        private bool _bUse = true;

        public bool _bInit = true;

        private string _ExTag;

        //private bool bButtonEvent = false;

        private Infragistics.Win.GradientStyle _gradient;
        #endregion

        #region 이벤트
        private ButtonClickTypeEnum _ButtonType = ButtonClickTypeEnum.Click;
        /// <summary>
        /// 클릭시 발생하는 이벤트
        /// </summary>
        //public new event EventHandler Click;
        #endregion

        #region enum
        /// <summary>
        /// 버튼 종류
        /// </summary>
        public enum ButtonClickTypeEnum 
        { 
            /// <summary>
            /// 클릭 형태 ( 일반 버튼 )
            /// </summary>
            Click, 
            /// <summary>
            /// 변화 없음. ( 종류 변경 )
            /// </summary>
            Change 
        }
        /// <summary>
        /// 버튼을 클릭했을 시 연결한 그리드에서 일어날 동작
        /// </summary>
        public enum LinkGridButtonType { Up, Down }
        #endregion

        #region 생성자
        /// <summary>
        /// MES-DAS 용 버튼
        /// </summary>
        public MESButton_Bottom()
        {
            InitializeComponent();

            _bColor = panel_b.Appearance.BackColor;
            _bDisColor = panel_b.Appearance.BackColorDisabled;            
            _ClickColor = Color.Yellow;
            _AlramColor = Color.IndianRed;
            _gradient = panel_b.Appearance.BackGradientStyle;
        }
        #endregion

        #region Property 리스트
        /// <summary>
        /// 클릭시 변경되는 색
        /// </summary>
        public Color ClickBackColor
        {
            get { return _ClickColor; }
            set { _ClickColor = value; }
        }

        /// <summary>
        /// 알람으로 사용할 색
        /// </summary>
        public Color AlarmColor
        {
            get { return _AlramColor; }
            set { _AlramColor = value; }
        }

        /// <summary>
        /// 버튼 클릭시 버튼 변경 형태
        /// </summary>
        public ButtonClickTypeEnum ButtonClickType
        {
            get { return _ButtonType; }
            set { _ButtonType = value; }
        }

        /// <summary>
        /// 외부 참조용 데이터
        /// </summary>
        public string ExTag
        {
            get { return _ExTag; }
            set { _ExTag = value; }
        }

        /// <summary>
        /// 버튼이 눌러졌는지...
        /// </summary>
        public bool ButtonPressed
        {
            get { return _bPress; }
            set
            {
                if (_bUse)
                {
                    _bPress = value;
                    if (_bPress)
                    {
                        panel_b.BorderStyle = Infragistics.Win.UIElementBorderStyle.Inset;
                        //panel_B.Appearance.BackColor = _ClickColor;
                        panel_b.Appearance.ImageBackground = global::SmartDas.Properties.Resources.버튼_09;
                        panel_b.Appearance.BackGradientStyle = Infragistics.Win.GradientStyle.None;
                    }
                    else
                    {
                        panel_b.BorderStyle = Infragistics.Win.UIElementBorderStyle.Raised;
                        //panel_B.Appearance.BackColor = _bColor;
                        panel_b.Appearance.ImageBackground = global::SmartDas.Properties.Resources.버튼_08;
                        panel_b.Appearance.BackGradientStyle = _gradient;
                    }

                    //if (ParentBox != null)
                    //{
                    //    if ( this._bInit )
                    //        ParentBox.SetSelectButtons(this);
                    //}
                }

                if (btnData != null)
                {
                    btnData.ButtonPressed = value;
                }
            }
        }

        /// <summary>
        /// 사용여부 - UseFlag 가 false면, 버튼 클릭, 상태 변경이 안됨.
        /// </summary>
        public bool UseFlag
        {
            get { return _bUse; }
            set 
            { 
                _bUse = value;

                if (!_bPress)
                {
                    if (_bUse)
                    {
                        panel_b.Appearance.BackColor = _bColor;
                        panel_b.Appearance.BackGradientStyle = _gradient;
                    }
                    else
                    {
                        panel_b.Appearance.BackColor = _bDisColor;
                        panel_b.Appearance.BackGradientStyle = Infragistics.Win.GradientStyle.None;
                    }
                }

                if (btnData != null)
                {
                    this.btnData.UseFlag = value;
                }
            }
        }

        /// <summary>
        /// 표시될 문자열
        /// </summary>
        [Browsable(true)]
        [EditorBrowsable(EditorBrowsableState.Always)]
        [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
        public override string Text
        {
            get { return label_b.Text; }
            set { label_b.Text = value; }
        }

        /// <summary>
        /// 문자열 세로 정렬 형태
        /// </summary>
        public Infragistics.Win.VAlign TextVAlign
        {
            get { return label_b.Appearance.TextVAlign; }
            set { label_b.Appearance.TextVAlign = value; }
        }

        /// <summary>
        /// 문자열 가로 정렬 형태
        /// </summary>
        public Infragistics.Win.HAlign TextHAlign
        {
            get { return label_b.Appearance.TextHAlign; }
            set { label_b.Appearance.TextHAlign = value; }
        }

        /// <summary>
        /// 데이터를 저장할 수 있는 Tag
        /// </summary>
        public new object Tag
        {
            get { return _tag; }
            set { _tag = value; }
        }

        /// <summary>
        /// 버튼과 연결할 그리드
        /// </summary>
        public MESGrid LinkGrid
        {
            get { return _grid; }
            set { _grid = value; }
        }

        /// <summary>
        /// 버튼과 연결할 버튼박스
        /// </summary>
        public ButtonBox LinkButtonBox
        {
            get { return _bBox; }
            set { _bBox = value; }
        }

        /// <summary>
        /// 버튼을 클릭할 시 연결된 그리드가 처리되는 형식
        /// </summary>
        public LinkGridButtonType LinkType
        {
            get { return _link; }
            set { _link = value; }
        }

        /// <summary>
        /// 버튼 클릭시 연결된 그리드 혹은 버튼 박스가 움직일 로우 수
        /// </summary>
        public int LinkMoveSize
        {
            get { return _iSize; }
            set { _iSize = value; }
        }

        /// <summary>
        /// 이 버튼을 포함할 버튼 박스
        /// </summary>
        public ButtonBox ParentBox
        {
            get { return _parent; }
            set { _parent = value; }
        }

        /// <summary>
        /// 그라데이션 형태
        /// </summary>
        public Infragistics.Win.GradientStyle BackGradientStyle
        {
            get { return _gradient; }
            set { _gradient = value; }
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
        #endregion

        #region 이벤트 메소드
        private void panel_B_MouseDown(object sender, MouseEventArgs e)
        {
            if (_bUse)
            {
                if (_ButtonType == ButtonClickTypeEnum.Click) //판넬을 마우스로 누르게되면 발생하는 이벤트
                {
                    panel_b.BorderStyle = Infragistics.Win.UIElementBorderStyle.Inset;
                    //panel_B.Appearance.BackColor = _ClickColor;
                    panel_b.Appearance.ImageBackground = global::SmartDas.Properties.Resources.버튼_09;
                    panel_b.Appearance.BackGradientStyle = Infragistics.Win.GradientStyle.None;
                }
                else
                {
                    _bPress = !_bPress;
                    if (btnData != null)
                        btnData.ButtonPressed = _bPress;

                    if (_bPress)
                    {
                        panel_b.BorderStyle = Infragistics.Win.UIElementBorderStyle.Inset;
                        //panel_B.Appearance.BackColor = _ClickColor;
                        panel_b.Appearance.ImageBackground = global::SmartDas.Properties.Resources.버튼_09;
                        panel_b.Appearance.BackGradientStyle = Infragistics.Win.GradientStyle.None;
                    }
                    else
                    {
                        panel_b.BorderStyle = Infragistics.Win.UIElementBorderStyle.Raised;
                        //panel_B.Appearance.BackColor = _bColor;
                        panel_b.Appearance.ImageBackground = global::SmartDas.Properties.Resources.버튼_08;
                        panel_b.Appearance.BackGradientStyle = _gradient;
                    }
                }
            }
        }

        private void panel_B_MouseUp(object sender, MouseEventArgs e)
        {
            if (_bUse)
            {
                if (_ButtonType == ButtonClickTypeEnum.Click)
                {
                    panel_b.BorderStyle = Infragistics.Win.UIElementBorderStyle.Raised;
                    //panel_B.Appearance.BackColor = _bColor;
                    panel_b.Appearance.ImageBackground = global::SmartDas.Properties.Resources.버튼_08;
                    panel_b.Appearance.BackGradientStyle = _gradient;
                }
            }
        }

        //private void label_b_Click(object sender, EventArgs e)
        //{
        //    if (_bUse)
        //    {
        //        if (!bButtonEvent)
        //        {
        //            bButtonEvent = true;
        //            if (Click != null)
        //            {
        //                Click(this, e);
        //            }

        //            if (_grid != null)
        //            {
        //                _grid.PageMove(this, _link, _iSize);
        //            }

        //            if (_bBox != null)
        //            {
        //                _bBox.PageMove(this, _link, _iSize);
        //            }
        //            bButtonEvent = false;
        //        }
        //    }
        //}

        private void NewMESButton_Bottom_FontChanged(object sender, EventArgs e)
        {
            label_b.Font = this.Font;
        }

        private void MESlabel_b_ForeColorChanged(object sender, EventArgs e)
        {
            label_b.ForeColor = this.ForeColor;
        }

        private void NewMESButton_Bottom_BackColorChanged(object sender, EventArgs e)
        {
            _bColor = this.BackColor;
            panel_b.Appearance.BackColor = _bColor;
        }
        #endregion

        #region 자체 메소드
        public void SetAlarmBackColor(bool nInit = false)
        {
            if (_bUse)
            {
                if (nInit)
                {
                    if (panel_b.BorderStyle != Infragistics.Win.UIElementBorderStyle.Inset)
                    {
                        panel_b.Appearance.BackColor = _bColor;
                        if (btnData != null)
                        {
                            btnData._thisColor = _bColor;
                        }
                    }
                }
                else
                {
                    if (panel_b.BorderStyle != Infragistics.Win.UIElementBorderStyle.Inset)
                    {
                        if (btnData != null)
                        {
                            if (btnData._thisColor != _AlramColor)
                            {
                                //panel_B.Appearance.BackColor = _AlramColor;
                                panel_b.Appearance.ImageBackground = global::SmartDas.Properties.Resources.버튼08;
                                btnData._thisColor = _AlramColor;
                            }
                            else
                            {
                                panel_b.Appearance.BackColor = _bColor;
                                btnData._thisColor = _bColor;
                            }
                        }
                    }
                }
            }
        }
        #endregion
    }
}
