<%@ page language="java" contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="template" uri="http://www.jahia.org/tags/templateLib" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="jcr" uri="http://www.jahia.org/tags/jcr" %>
<%@ taglib prefix="ui" uri="http://www.jahia.org/tags/uiComponentsLib" %>
<%@ taglib prefix="functions" uri="http://www.jahia.org/tags/functions" %>
<%@ taglib prefix="query" uri="http://www.jahia.org/tags/queryLib" %>
<%@ taglib prefix="utility" uri="http://www.jahia.org/tags/utilityLib" %>
<%--@elvariable id="currentNode" type="org.jahia.services.content.JCRNodeWrapper"--%>
<%--@elvariable id="out" type="java.io.PrintWriter"--%>
<%--@elvariable id="script" type="org.jahia.services.render.scripting.Script"--%>
<%--@elvariable id="scriptInfo" type="java.lang.String"--%>
<%--@elvariable id="workspace" type="java.lang.String"--%>
<%--@elvariable id="renderContext" type="org.jahia.services.render.RenderContext"--%>
<%--@elvariable id="currentResource" type="org.jahia.services.render.Resource"--%>
<%--@elvariable id="url" type="org.jahia.services.render.URLGenerator"--%>
<%--@elvariable id="currentUser" type="org.jahia.services.usermanager.JahiaUser"--%>
<%--@elvariable id="currentAliasUser" type="org.jahia.services.usermanager.JahiaUser"--%>


<c:set var="linkedInNode"/>
<c:forEach var="node" items="${jcr:getDescendantNodes(renderContext.site, 'joant:linkedInOAuthSettings')}">
    <c:set var="linkedInNode" value="${node}"/>
</c:forEach>

<c:if test="${(not renderContext.liveMode and linkedInNode eq '') or (linkedInNode ne '' and not linkedInNode.properties.isActivate.boolean)}">
    <div style="color: red;">
        <fmt:message key="socialButton.linkedInButton.error.connectorNotConfigured"/>
    </div>
</c:if>

<c:if test="${linkedInNode ne '' and linkedInNode.properties.isActivate.boolean and (not renderContext.loggedIn or renderContext.editMode)}">
    <template:addResources type="css" resources="joaLinkedInButton.css"/>

    <template:addResources>
        <script>
            function connectToLinkedIn${fn:replace(currentNode.identifier, '-', '')}() {
                var popup = window.open('', "LinkedIn Authorization", "menubar=no,status=no,scrollbars=no,width=1145,height=725,modal=yes,alwaysRaised=yes");
                var xhr = new XMLHttpRequest();
                xhr.open('GET', '<c:url value="${url.base}${renderContext.site.home.path}"/>.connectToLinkedInAction.do');
                xhr.setRequestHeader('Accept', 'application/json;');
                xhr.send();
                xhr.onreadystatechange = function () {
                    if (xhr.readyState != 4 || xhr.status != 200) return;
                    var json = JSON.parse(xhr.responseText);
                    popup.location.href = json.authorizationUrl;
                    window.addEventListener('message', function (event) {
                        if (event.data.authenticationIsDone) {
                            setTimeout(function () {
                                popup.close();
                                if (event.data.isAuthenticate) {
                                    window.location.search = 'site=${renderContext.site.siteKey}';
                                }
                            }, 5000);
                        }
                    });
                };
            }
        </script>
    </template:addResources>
    <a href="#" style="color: transparent;"
       onclick="connectToLinkedIn${fn:replace(currentNode.identifier, '-', '')}();return false;"
       <c:if test="${renderContext.editMode}">disabled</c:if> >
        <img class="social-login-logo linkedin-social-logo"  src="<c:url value="${url.currentModule}/img/sign-in-with-linkedin.png"/>">

    </a>
</c:if>
