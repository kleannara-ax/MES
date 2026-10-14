namespace SmartDas.POPUP
{
    partial class BaseProgressForm
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            Infragistics.Win.Appearance appearance1 = new Infragistics.Win.Appearance();
            this.pnlBody = new Infragistics.Win.Misc.UltraPanel();
            this.indProgress = new CircularProgressControl();
            this.pnlBody.ClientArea.SuspendLayout();
            this.pnlBody.SuspendLayout();
            this.SuspendLayout();
            // 
            // pnlBody
            // 
            appearance1.BorderColor = System.Drawing.Color.Gray;
            this.pnlBody.Appearance = appearance1;
            this.pnlBody.BorderStyle = Infragistics.Win.UIElementBorderStyle.Solid;
            // 
            // pnlBody.ClientArea
            // 
            this.pnlBody.ClientArea.Controls.Add(this.indProgress);
            this.pnlBody.Dock = System.Windows.Forms.DockStyle.Fill;
            this.pnlBody.Location = new System.Drawing.Point(0, 0);
            this.pnlBody.Name = "pnlBody";
            this.pnlBody.Size = new System.Drawing.Size(306, 93);
            this.pnlBody.TabIndex = 4;
            // 
            // indProgress
            // 
            this.indProgress.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.indProgress.BackColor = System.Drawing.Color.Black;
            this.indProgress.CenterMessage = "0%";
            this.indProgress.Font = new System.Drawing.Font("맑은 고딕", 13F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.indProgress.ForeColor = System.Drawing.Color.Lime;
            this.indProgress.InnerRadiousFactor = 0.6F;
            this.indProgress.Interval = 60;
            this.indProgress.IsShowMessage = true;
            this.indProgress.Location = new System.Drawing.Point(2, 2);
            this.indProgress.Message = "조회중...";
            this.indProgress.MessagePosition = CircularProgressControl.MessagePositionType.Right;
            this.indProgress.MinimumSize = new System.Drawing.Size(28, 28);
            this.indProgress.Name = "indProgress";
            this.indProgress.OuterRadiousFactor = 0.7F;
            this.indProgress.Percent = 0D;
            this.indProgress.Rotation = CircularProgressControl.Direction.CLOCKWISE;
            this.indProgress.ShowTime = true;
            this.indProgress.Size = new System.Drawing.Size(300, 87);
            this.indProgress.SpokesCount = 50;
            this.indProgress.SpokeThick = 2;
            this.indProgress.StartAngle = 270F;
            this.indProgress.TabIndex = 0;
            this.indProgress.TickColor = System.Drawing.Color.Lime;
            this.indProgress.Type = CircularProgressControl.ControlType.PROGRESS;
            // 
            // BaseProgressForm
            // 
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.None;
            this.BackColor = System.Drawing.Color.White;
            this.ClientSize = new System.Drawing.Size(306, 93);
            this.Controls.Add(this.pnlBody);
            this.DoubleBuffered = true;
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.None;
            this.Name = "BaseProgressForm";
            this.ShowInTaskbar = false;
            this.StartPosition = System.Windows.Forms.FormStartPosition.Manual;
            this.Text = "BaseProgressForm";
            this.Load += new System.EventHandler(this.BaseProgressForm_Load);
            this.pnlBody.ClientArea.ResumeLayout(false);
            this.pnlBody.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private Infragistics.Win.Misc.UltraPanel pnlBody;
        public CircularProgressControl indProgress;

    }
}