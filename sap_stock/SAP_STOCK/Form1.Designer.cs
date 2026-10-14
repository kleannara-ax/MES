namespace SAP_STOCK
{
    partial class Form1
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

        #region Windows Form 디자이너에서 생성한 코드

        /// <summary>
        /// 디자이너 지원에 필요한 메서드입니다.
        /// 이 메서드의 내용을 코드 편집기로 수정하지 마십시오.
        /// </summary>
        private void InitializeComponent()
        {
            this.splitContainer1 = new System.Windows.Forms.SplitContainer();
            this.btnClean = new System.Windows.Forms.Button();
            this.btnFind = new System.Windows.Forms.Button();
            this.label4 = new System.Windows.Forms.Label();
            this.label3 = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.label1 = new System.Windows.Forms.Label();
            this.txtLOCA = new System.Windows.Forms.TextBox();
            this.txtMATNR = new System.Windows.Forms.TextBox();
            this.txtLOTNO = new System.Windows.Forms.TextBox();
            this.txtWERKS = new System.Windows.Forms.TextBox();
            this.grdRtn = new System.Windows.Forms.DataGridView();
            this.btnFileFind = new System.Windows.Forms.Button();
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).BeginInit();
            this.splitContainer1.Panel1.SuspendLayout();
            this.splitContainer1.Panel2.SuspendLayout();
            this.splitContainer1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.grdRtn)).BeginInit();
            this.SuspendLayout();
            // 
            // splitContainer1
            // 
            this.splitContainer1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.splitContainer1.Location = new System.Drawing.Point(0, 0);
            this.splitContainer1.Name = "splitContainer1";
            this.splitContainer1.Orientation = System.Windows.Forms.Orientation.Horizontal;
            // 
            // splitContainer1.Panel1
            // 
            this.splitContainer1.Panel1.Controls.Add(this.btnFileFind);
            this.splitContainer1.Panel1.Controls.Add(this.btnClean);
            this.splitContainer1.Panel1.Controls.Add(this.btnFind);
            this.splitContainer1.Panel1.Controls.Add(this.label4);
            this.splitContainer1.Panel1.Controls.Add(this.label3);
            this.splitContainer1.Panel1.Controls.Add(this.label2);
            this.splitContainer1.Panel1.Controls.Add(this.label1);
            this.splitContainer1.Panel1.Controls.Add(this.txtLOCA);
            this.splitContainer1.Panel1.Controls.Add(this.txtMATNR);
            this.splitContainer1.Panel1.Controls.Add(this.txtLOTNO);
            this.splitContainer1.Panel1.Controls.Add(this.txtWERKS);
            // 
            // splitContainer1.Panel2
            // 
            this.splitContainer1.Panel2.Controls.Add(this.grdRtn);
            this.splitContainer1.Size = new System.Drawing.Size(1262, 314);
            this.splitContainer1.SplitterDistance = 65;
            this.splitContainer1.TabIndex = 0;
            // 
            // btnClean
            // 
            this.btnClean.Location = new System.Drawing.Point(803, 13);
            this.btnClean.Name = "btnClean";
            this.btnClean.Size = new System.Drawing.Size(102, 42);
            this.btnClean.TabIndex = 9;
            this.btnClean.Text = "지우기";
            this.btnClean.UseVisualStyleBackColor = true;
            this.btnClean.Click += new System.EventHandler(this.btnClean_Click);
            // 
            // btnFind
            // 
            this.btnFind.Location = new System.Drawing.Point(578, 13);
            this.btnFind.Name = "btnFind";
            this.btnFind.Size = new System.Drawing.Size(102, 42);
            this.btnFind.TabIndex = 8;
            this.btnFind.Text = "조회";
            this.btnFind.UseVisualStyleBackColor = true;
            this.btnFind.Click += new System.EventHandler(this.btnFind_Click);
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Location = new System.Drawing.Point(429, 18);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(67, 12);
            this.label4.TabIndex = 7;
            this.label4.Text = "LOCATION";
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(141, 18);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(49, 12);
            this.label3.TabIndex = 6;
            this.label3.Text = "MATNR";
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(308, 18);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(47, 12);
            this.label2.TabIndex = 5;
            this.label2.Text = "LOTNO";
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(18, 18);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(47, 12);
            this.label1.TabIndex = 4;
            this.label1.Text = "WERKS";
            // 
            // txtLOCA
            // 
            this.txtLOCA.Location = new System.Drawing.Point(431, 33);
            this.txtLOCA.Name = "txtLOCA";
            this.txtLOCA.Size = new System.Drawing.Size(100, 21);
            this.txtLOCA.TabIndex = 3;
            // 
            // txtMATNR
            // 
            this.txtMATNR.CharacterCasing = System.Windows.Forms.CharacterCasing.Upper;
            this.txtMATNR.Location = new System.Drawing.Point(143, 33);
            this.txtMATNR.Name = "txtMATNR";
            this.txtMATNR.Size = new System.Drawing.Size(148, 21);
            this.txtMATNR.TabIndex = 1;
            // 
            // txtLOTNO
            // 
            this.txtLOTNO.CharacterCasing = System.Windows.Forms.CharacterCasing.Upper;
            this.txtLOTNO.Location = new System.Drawing.Point(310, 33);
            this.txtLOTNO.Name = "txtLOTNO";
            this.txtLOTNO.Size = new System.Drawing.Size(100, 21);
            this.txtLOTNO.TabIndex = 2;
            // 
            // txtWERKS
            // 
            this.txtWERKS.CharacterCasing = System.Windows.Forms.CharacterCasing.Upper;
            this.txtWERKS.Location = new System.Drawing.Point(20, 33);
            this.txtWERKS.Name = "txtWERKS";
            this.txtWERKS.Size = new System.Drawing.Size(100, 21);
            this.txtWERKS.TabIndex = 0;
            this.txtWERKS.Text = "P100";
            // 
            // grdRtn
            // 
            this.grdRtn.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.grdRtn.Dock = System.Windows.Forms.DockStyle.Fill;
            this.grdRtn.Location = new System.Drawing.Point(0, 0);
            this.grdRtn.Name = "grdRtn";
            this.grdRtn.RowTemplate.Height = 23;
            this.grdRtn.Size = new System.Drawing.Size(1262, 245);
            this.grdRtn.TabIndex = 0;
            // 
            // btnFileFind
            // 
            this.btnFileFind.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.btnFileFind.Location = new System.Drawing.Point(1148, 13);
            this.btnFileFind.Name = "btnFileFind";
            this.btnFileFind.Size = new System.Drawing.Size(102, 42);
            this.btnFileFind.TabIndex = 10;
            this.btnFileFind.Text = "파일 조회";
            this.btnFileFind.UseVisualStyleBackColor = true;
            this.btnFileFind.Click += new System.EventHandler(this.btnFileFind_Click);
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(1262, 314);
            this.Controls.Add(this.splitContainer1);
            this.Name = "Form1";
            this.Text = "재고확인(운영, DPP [10.2.14.200])";
            this.splitContainer1.Panel1.ResumeLayout(false);
            this.splitContainer1.Panel1.PerformLayout();
            this.splitContainer1.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).EndInit();
            this.splitContainer1.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.grdRtn)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.SplitContainer splitContainer1;
        private System.Windows.Forms.Button btnFind;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.TextBox txtLOCA;
        private System.Windows.Forms.TextBox txtMATNR;
        private System.Windows.Forms.TextBox txtLOTNO;
        private System.Windows.Forms.TextBox txtWERKS;
        private System.Windows.Forms.DataGridView grdRtn;
        private System.Windows.Forms.Button btnClean;
        private System.Windows.Forms.Button btnFileFind;
    }
}

