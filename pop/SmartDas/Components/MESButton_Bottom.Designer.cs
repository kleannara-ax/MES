namespace SmartDas.Components
{
    partial class MESButton_Bottom
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
            this.panel_b = new Infragistics.Win.Misc.UltraPanel();
            this.label_b = new Infragistics.Win.Misc.UltraLabel();
            this.panel_b.ClientArea.SuspendLayout();
            this.panel_b.SuspendLayout();
            this.SuspendLayout();
            // 
            // panel_b
            // 
            appearance2.BorderAlpha = Infragistics.Win.Alpha.UseAlphaLevel;
            appearance2.Cursor = System.Windows.Forms.Cursors.Hand;
            this.panel_b.Appearance = appearance2;
            this.panel_b.BorderStyle = Infragistics.Win.UIElementBorderStyle.None;
            // 
            // panel_b.ClientArea
            // 
            this.panel_b.ClientArea.Controls.Add(this.label_b);
            this.panel_b.Dock = System.Windows.Forms.DockStyle.Fill;
            this.panel_b.Font = new System.Drawing.Font("맑은 고딕", 24F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.panel_b.ImeMode = System.Windows.Forms.ImeMode.NoControl;
            this.panel_b.Location = new System.Drawing.Point(0, 0);
            this.panel_b.Margin = new System.Windows.Forms.Padding(0);
            this.panel_b.Name = "panel_b";
            this.panel_b.Size = new System.Drawing.Size(164, 54);
            this.panel_b.TabIndex = 2;
            // 
            // label_b
            // 
            appearance1.BackColor = System.Drawing.Color.Transparent;
            appearance1.TextHAlignAsString = "Center";
            appearance1.TextVAlignAsString = "Middle";
            this.label_b.Appearance = appearance1;
            this.label_b.Dock = System.Windows.Forms.DockStyle.Fill;
            this.label_b.Font = new System.Drawing.Font("맑은 고딕", 20.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label_b.Location = new System.Drawing.Point(0, 0);
            this.label_b.Margin = new System.Windows.Forms.Padding(0);
            this.label_b.Name = "label_b";
            this.label_b.Size = new System.Drawing.Size(164, 54);
            this.label_b.TabIndex = 0;
            // 
            // MESButton_Bottom
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.panel_b);
            this.Name = "MESButton_Bottom";
            this.Size = new System.Drawing.Size(164, 54);
            this.panel_b.ClientArea.ResumeLayout(false);
            this.panel_b.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        public Infragistics.Win.Misc.UltraPanel panel_b;
        public Infragistics.Win.Misc.UltraLabel label_b;
    }
}
