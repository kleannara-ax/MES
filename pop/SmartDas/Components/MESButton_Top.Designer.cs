namespace SmartDas.Components
{
    partial class MESButton_Top
    {
        /// <summary> 
        /// 필수 디자이너 변수입니다.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary> 
        /// 사용 중인 모든 리소스를 정리합니다.
        /// </summary>
        /// <param name="disposing">관리되는 리소스를 삭제해야 하면 true이고, 그렇지 않으면 false입니다.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region 구성 요소 디자이너에서 생성한 코드

        /// <summary> 
        /// 디자이너 지원에 필요한 메서드입니다. 
        /// 이 메서드의 내용을 코드 편집기로 수정하지 마십시오.
        /// </summary>
        private void InitializeComponent()
        {
            Infragistics.Win.Appearance appearance2 = new Infragistics.Win.Appearance();
            Infragistics.Win.Appearance appearance1 = new Infragistics.Win.Appearance();
            this.panel = new Infragistics.Win.Misc.UltraPanel();
            this.label = new Infragistics.Win.Misc.UltraLabel();
            this.panel.ClientArea.SuspendLayout();
            this.panel.SuspendLayout();
            this.SuspendLayout();
            // 
            // panel
            // 
            appearance2.BorderAlpha = Infragistics.Win.Alpha.UseAlphaLevel;
            appearance2.Cursor = System.Windows.Forms.Cursors.Hand;
            this.panel.Appearance = appearance2;
            this.panel.BorderStyle = Infragistics.Win.UIElementBorderStyle.None;
            // 
            // panel.ClientArea
            // 
            this.panel.ClientArea.Controls.Add(this.label);
            this.panel.Dock = System.Windows.Forms.DockStyle.Fill;
            this.panel.Font = new System.Drawing.Font("휴먼둥근헤드라인", 24F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.panel.ImeMode = System.Windows.Forms.ImeMode.NoControl;
            this.panel.Location = new System.Drawing.Point(0, 0);
            this.panel.Margin = new System.Windows.Forms.Padding(0);
            this.panel.Name = "panel";
            this.panel.Size = new System.Drawing.Size(164, 54);
            this.panel.TabIndex = 0;
            this.panel.MouseDownClient += new System.Windows.Forms.MouseEventHandler(this.Panel_MouseDown);
            this.panel.MouseUpClient += new System.Windows.Forms.MouseEventHandler(this.Panel_MouseUp);
            // 
            // label
            // 
            appearance1.BackColor = System.Drawing.Color.Transparent;
            appearance1.TextHAlignAsString = "Center";
            appearance1.TextVAlignAsString = "Middle";
            this.label.Appearance = appearance1;
            this.label.Dock = System.Windows.Forms.DockStyle.Fill;
            this.label.Font = new System.Drawing.Font("맑은 고딕", 20.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label.Location = new System.Drawing.Point(0, 0);
            this.label.Margin = new System.Windows.Forms.Padding(0);
            this.label.Name = "label";
            this.label.Size = new System.Drawing.Size(164, 54);
            this.label.TabIndex = 0;
            this.label.Click += new System.EventHandler(this.label_Click);
            this.label.MouseDown += new System.Windows.Forms.MouseEventHandler(this.Panel_MouseDown);
            this.label.MouseUp += new System.Windows.Forms.MouseEventHandler(this.Panel_MouseUp);
            // 
            // MESButton_Top
            // 
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.None;
            this.BackColor = System.Drawing.Color.Transparent;
            this.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.Controls.Add(this.panel);
            this.DoubleBuffered = true;
            this.Font = new System.Drawing.Font("맑은 고딕", 24F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.Margin = new System.Windows.Forms.Padding(0);
            this.Name = "MESButton_Top";
            this.Size = new System.Drawing.Size(164, 54);
            this.BackColorChanged += new System.EventHandler(this.NewMESButton_Top_BackColorChanged);
            this.FontChanged += new System.EventHandler(this.NewMESButton_Top_FontChanged);
            this.ForeColorChanged += new System.EventHandler(this.MESLabel_ForeColorChanged);
            this.panel.ClientArea.ResumeLayout(false);
            this.panel.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        public Infragistics.Win.Misc.UltraLabel label;
        public Infragistics.Win.Misc.UltraPanel panel;

    }
}
