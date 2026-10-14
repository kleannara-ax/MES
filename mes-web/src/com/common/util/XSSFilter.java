package com.common.util;

import java.io.IOException;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;

public class XSSFilter implements Filter {

	public FilterConfig fConfig;

	/* (non-Javadoc)
	 * @see javax.servlet.Filter#destroy()
	 */
	
	public void destroy() {
		this.fConfig = null;
	}

	/* (non-Javadoc)
	 * @see javax.servlet.Filter#doFilter(javax.servlet.ServletRequest, javax.servlet.ServletResponse, javax.servlet.FilterChain)
	 */
	
	public void doFilter(ServletRequest req, ServletResponse res,
			FilterChain fChain) throws IOException, ServletException {
		fChain.doFilter(new XSSRequestWrapper((HttpServletRequest)req), res);
	}

	/* (non-Javadoc)
	 * @see javax.servlet.Filter#init(javax.servlet.FilterConfig)
	 */
	
	public void init(FilterConfig fConfig) throws ServletException {
		this.fConfig = fConfig;
	}
}
