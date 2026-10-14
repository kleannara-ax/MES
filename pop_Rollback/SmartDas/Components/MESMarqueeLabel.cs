using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Runtime.InteropServices;

namespace SmartDas.Components
{
    public partial class MESMarqueeLabel : UserControl
    {
        #region 멤버 변수
        private object _tag;
        private LabelTypeEnum _LabelType;

        private Control _MoveControl;
        /// <summary>
        /// 클릭시 발생
        /// </summary>
        //public new event EventHandler Click;

        private Color _LabelColor;
        private Color _TransparentColor;
        private Color _ContentColor;

        private string MarqueeText;
        public int ScrollPixelAmount = 10;
        public System.Windows.Forms.Timer tmrScroll;
        private int position = 0;
        private MarqueeTypeEnum _marqueeType;

        #endregion

        #region 속성 리스트
        /// <summary>
        /// 라벨 종류
        /// </summary>
        public enum LabelTypeEnum 
        {
            Label, Transparent, Content
        }

        /// <summary>
        /// Marquee방향 설정
        /// </summary>
        public enum MarqueeTypeEnum
        {
            LeftToRight, RightToLeft
        }

        public MarqueeTypeEnum MarqueeType

        {
            get { return _marqueeType; }
            set { _marqueeType = value; }
        }
        /// <summary>
        /// 
        /// </summary>
        public Color ColorLabel
        {
            get { return _LabelColor; }
            set { _LabelColor = value; }
        }

        /// <summary>
        /// 
        /// </summary>
        public Color ColorReadOnly
        {
            get { return _TransparentColor; }
            set { _TransparentColor = value; }
        }

        /// <summary>
        /// 
        /// </summary>
        public Color ColorContent
        {
            get { return _ContentColor; }
            set { _ContentColor = value; }
        }

        /// <summary>
        /// 라벨의 종류
        /// </summary>
        public LabelTypeEnum LabelType
        {
            get { return _LabelType; }
            set 
            {
                _LabelType = value;

                switch (value)
                {
                    case LabelTypeEnum.Label:
                        this.BackColor = _LabelColor;
                        BackGradientStyle = Infragistics.Win.GradientStyle.Default;
                        break;
                    case LabelTypeEnum.Transparent:
                        this.BackColor = _TransparentColor;
                        BackGradientStyle = Infragistics.Win.GradientStyle.None;
                        break;
                    case LabelTypeEnum.Content:
                        this.BackColor = _ContentColor;
                        BackGradientStyle = Infragistics.Win.GradientStyle.None;
                        break;
                }
            }
        }

        /// <summary>
        /// 그라데이션 형태
        /// </summary>
        public Infragistics.Win.GradientStyle BackGradientStyle
        {
            get { return label.Appearance.BackGradientStyle; }
            set { label.Appearance.BackGradientStyle = value; }
        }

        public Control MoveControl
        {
            get { return _MoveControl; }
            set { _MoveControl = value; }
        }
        #endregion

        /// <summary>
        /// MES-DAS용 라벨
        /// </summary>
        public MESMarqueeLabel()
        {
            InitializeComponent();

            _LabelColor = Color.LightGreen;
            _TransparentColor = Color.Transparent;
            _ContentColor = Color.Transparent;
            _marqueeType = MarqueeTypeEnum.RightToLeft;

            label.Dock = DockStyle.Fill;

            LabelType = LabelTypeEnum.Label;

            this.tmrScroll = new System.Windows.Forms.Timer(new System.ComponentModel.Container());
            this.tmrScroll.Tick += new System.EventHandler(this.tmrScroll_Tick);
            this.Size = new System.Drawing.Size(360, 104);

            DoubleBuffered = true;
            ResizeRedraw = true;

            tmrScroll.Enabled = true;
        }

        private delegate void SetTextCallback(string text);
        /// <summary>
        /// 표시될 문자열
        /// </summary>
        [Browsable(true)]
        [EditorBrowsable(EditorBrowsableState.Always)]
        [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
        public override string Text
        {
            get { return MarqueeText ; }
            set
            {
                SetText(value);
            }
        }

        private void SetText(string text)
        {
            if (label.InvokeRequired)
            {
                SetTextCallback d = new SetTextCallback(SetText);
                Invoke(d, new object[] { text });
            }
            else
            {
                MarqueeText = text;
                // label.Text = text;
            }
        }


        /// <summary>
        /// 표시될 문자열 위치
        /// </summary>
        public int Position
        {
            get { return position; }
            set { position = value; }
        }

        /// <summary>
        /// 문자열 세로 정렬 형태
        /// </summary>
        public Infragistics.Win.VAlign TextVAlign
        {
            get { return label.Appearance.TextVAlign; }
            set { label.Appearance.TextVAlign = value; }
        }

        /// <summary>
        /// 문자열 가로 정렬 형태
        /// </summary>
        public Infragistics.Win.HAlign TextHAlign
        {
            get { return label.Appearance.TextHAlign; }
            set { label.Appearance.TextHAlign = value; }
        }

        /// <summary>
        /// 데이터를 저장할 수 있는 Tag
        /// </summary>
        public new object Tag
        {
            get { return _tag; }
            set { _tag = value; }
        }


        private void MESMarqueeLabel_FontChanged(object sender, EventArgs e)
        {
            label.Font = this.Font;
        }

        private void MESMarqueeLabel_ForeColorChanged(object sender, EventArgs e)
        {
            label.ForeColor = this.ForeColor;
        }

        private void MESMarqueeLabel_BackColorChanged(object sender, EventArgs e)
        {
            switch (LabelType)
            {
                case LabelTypeEnum.Label:
                    _LabelColor = this.BackColor;
                    break;
                case LabelTypeEnum.Transparent:
                    _TransparentColor = this.BackColor;
                    break;
                case LabelTypeEnum.Content:
                    _ContentColor = this.BackColor;
                    break;
            }
        }

        private delegate void SetColorCallback(Color color);

        public void SetColor(Color color)
        {
            if (this.InvokeRequired)
            {
                SetColorCallback d = new SetColorCallback(SetColor);
                Invoke(d, new object[] { color });
            }
            else
            {
                this.BackColor = color;
            }
        }

        private void tmrScroll_Tick(object sender, System.EventArgs e)
        {
            switch (_marqueeType)
            {
                case MarqueeTypeEnum.LeftToRight:
                    position += ScrollPixelAmount;
                    break;
                case MarqueeTypeEnum.RightToLeft:
                    position -= ScrollPixelAmount;
                    break;
            }
            
            Invalidate();
        }

        protected override void OnPaint(System.Windows.Forms.PaintEventArgs e)
        {
            base.OnPaint(e);
            switch (_marqueeType)
            {
                case MarqueeTypeEnum.LeftToRight:
                    if (position > Width)
                    {
                        position = -(int)e.Graphics.MeasureString(this.MarqueeText, Font).Width;
                    }
                    break;
                case MarqueeTypeEnum.RightToLeft:
                    if (Math.Abs(position) > (int)e.Graphics.MeasureString(this.MarqueeText, Font).Width) //Width)
                    {
                        if (!(position > 0))
                            position = this.Width; //-(int)e.Graphics.MeasureString(this.MarqueeText, Font).Width;
                    }
                    break;
            }
            
            e.Graphics.DrawString(this.MarqueeText, Font, new SolidBrush(ForeColor), position, ((label.Height - label.Font.Height) / 2));
        }
    }
}
